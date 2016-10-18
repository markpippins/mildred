#! /usr/bin/python

import os, json, sys, logging, traceback, time

from mutagen.id3 import ID3, ID3NoHeaderError
from mutagen.flac import FLAC, FLACNoHeaderError, FLACVorbisError
from mutagen.apev2 import APEv2, APENoHeaderError, APEUnsupportedVersionError
from mutagen.oggvorbis import OggVorbis, OggVorbisHeaderError
from mutagen import MutagenError

import cache2
import config
import library
import ops
import sql

from errors import ElasticSearchError, BaseClassException

LOG = logging.getLogger(__name__)

DELIM = ','
READ = 'read'
KNOWN = 'known_fields'
METADATA = 'document_metadata'


def add_field(doc_format, field_name):
    """add an attribute to document_metadata for the specified document_type"""
    keygroup = 'fields'
    if field_name in get_fields(doc_format): return
    sql.insert_values(METADATA, ['document_format', 'attribute_name'], [doc_format.upper(), field_name])

    key = cache2.get_key(keygroup, doc_format)
    cache2.clear_items2(key)
    cache2.delete_key(key)

def get_fields(doc_format):
    """get attributes from document_metadata for the specified document_type"""
    keygroup = 'fields'
    if not cache2.key_exists(keygroup, doc_format):
        key = cache2.create_key(keygroup, doc_format)
        rows = sql.retrieve_values('document_metadata', ['active_flag', 'document_format', 'attribute_name'], ['1', doc_format.upper()])
        cache2.add_items(keygroup, doc_format, [row[2] for row in rows])

    return cache2.get_items(keygroup, doc_format)


def get_known_fields(doc_format):
    """retrieve all attributes, innnncluding unused ones, from document_metadata for the specified document_type"""
    if not cache2.key_exists(KNOWN, doc_format):
        key = cache2.create_key(KNOWN, doc_format)
        rows = sql.retrieve_values('document_metadata', ['document_format', 'attribute_name'], [doc_format.upper()])
        cache2.add_items(KNOWN, doc_format, [row[1] for row in rows])

    return cache2.get_items(KNOWN, doc_format)


class Reader:
    def __init__(self):
        self.document_type = config.DOCUMENT

    def get_supported_extensions(self):
        result = ()
        for file_handler in self.get_file_handlers():
            for extension in file_handler.extensions:
                if extension not in result:
                    result += (extension,)

        return result

    def has_handler_for(self, filename):
        if filename.lower().startswith('incomplete~') or filename.lower().startswith('~incomplete'):
            return False

        for file_handler in self.get_file_handlers():
            for extension in file_handler.extensions:
                if filename.endswith(extension):
                    return True

    def read(self, asset, data, file_handler_name=None, force_read=False):
        for file_handler in self.get_file_handlers():
            if file_handler_name is None or file_handler.name == file_handler_name:
                if asset.ext in file_handler.extensions or '*' in file_handler.extensions or force_read:
                    if not ops.operation_in_cache(asset.absolute_path, READ, file_handler.name):
                        LOG.debug("%s reading file: %s" % (file_handler.name, asset.short_name()))
                        if file_handler.handle_file(asset, data):
                            library.record_file_read(file_handler.name, asset)

    def get_file_handlers(self):
        return MutagenID3(), MutagenFLAC(), MutagenAPEv2(), MutagenOggVorbis()


class FileHandler(object):
    def __init__(self, name, *extensions):
        self.name = name
        self.extensions = extensions

    def handle_exception(self, exception, asset, data):

        if isinstance(exception, IOError):
            pass


        else:
            error_data = { 'reader:': self.name, 'error': exception.__class__.__name__, 'details': exception.message }
            
            data['has_error'] = True
            data['errors'].append(error_data)

            library.record_error(exception)

    def handle_file(self, asset, data):
        raise BaseClassException(FileHandler)

# class Archive(FileHandler)
#     decompress files into temp  and push content into path context. Deference file paths and substitute archive path/name for temp location


class Mutagen(FileHandler):
    def __init__(self, name, *extensions):
        super(Mutagen, self).__init__(name, *extensions)


    def handle_file(self, asset, data):
        read_failed = False

        try:
            ops.record_op_begin('read', self.name, asset.absolute_path, asset.esid)
            self.read_tags(asset, data)
            
            return True

        except ID3NoHeaderError, err:
            read_failed = True
            if asset.absolute_path.lower().endswith('mp3'):
                self.handle_exception(err, asset, data)

        except UnicodeEncodeError, err:
            read_failed = True
            self.handle_exception(err, asset, data)

        except UnicodeDecodeError, err:
            read_failed = True
            self.handle_exception(err, asset, data)

        except FLACNoHeaderError, err:
            read_failed = True
            self.handle_exception(err, asset, data)

        except FLACVorbisError, err:
            read_failed = True
            self.handle_exception(err, asset, data)

        except APENoHeaderError, err:
            read_failed = True
            self.handle_exception(err, asset, data)

        except OggVorbisHeaderError, err:
            read_failed = True
            self.handle_exception(err, asset, data)

        except MutagenError, err:
            if isinstance(err.args[0], IOError):
                fs_avail = False
                while fs_avail == False:
                    ops.check_status()
                    print "file system offline, retrying in 5 seconds..." 
                    time.sleep(5)
                    fs_avail = os.access(asset.absolute_path, os.R_OK) 

                self.read_tags(asset, data)
                return True

        except Exception, err:
            read_failed = True
            self.handle_exception(err, asset, data)

        finally:
            ops.record_op_complete('read', self.name, asset.absolute_path, asset.esid, op_failed=read_failed)


    def read_tags(self, asset, data):
        raise BaseClassException(Mutagen)


class MutagenAPEv2(Mutagen):
    def __init__(self):
        super(MutagenAPEv2, self).__init__('mutagen-apev2', 'ape', 'mpc')

    def read_tags(self, asset, data):
        ape_data = {}
        document = APEv2(asset.absolute_path)
        for item in document.items():
            if len(item) < 2: continue

            key = item[0]
            value = item[1].value
            
            ape_data[key] = value
            if key not in get_known_fields('ape'):
                add_field('ape', key)

        if len(ape_data) > 0:
            ape_data['_reader'] = self.name
            data['properties'].append(ape_data)


class MutagenFLAC(Mutagen):
    def __init__(self):
        super(MutagenFLAC, self).__init__('mutagen-flac', 'flac')

    def read_tags(self, asset, data):
        flac_data = {}
        document = FLAC(asset.absolute_path)
        for tag in document.tags:
            if len(tag) < 2: continue
            
            if tag[0] not in get_known_fields('flac'):
                add_field('flac', tag[0])

            key = tag[0]
            value = tag[1]
            if 'key' == 'COVERART':
                continue
            flac_data[key] = value

        for tag in document.vc:
            if tag[0] not in get_known_fields('flac.vc'):
                add_field('flac.vc', tag[0])

            key = tag[0]
            value = tag[1]
            if 'key' == 'COVERART':
                continue
            flac_data[key] = value

        if len(flac_data) > 0:
            flac_data['_reader'] = self.name
            data['properties'].append(flac_data)


class MutagenID3(Mutagen):
    def __init__(self):
        super(MutagenID3, self).__init__('mutagen-id3', 'mp3', 'flac')

    def read_tags(self, asset, data):
        document = ID3(asset.absolute_path)
        metadata = document.pprint() # gets all metadata
        tags = [x.split('=',1) for x in metadata.split('\n')] # substring[0:] is redundant

        id3_data = {}
        for tag in tags:
            if len(tag) < 2: continue

            key = tag[0]
            value = tag[1]

            if key in get_fields('ID3V2'):
                id3_data[key] = value

            if key == "TXXX":
                for sub_field in get_fields('ID3V2.TXXX'):
                    if sub_field in value:
                        subtags = value.split('=')
                        subkey=subtags[0].replace(' ', '_').upper()
                        id3_data[subkey] = subtags[1]
                
                        if subkey not in get_known_fields('ID3V2.TXXX'):
                            add_field('ID3V2.TXXX', key)

            elif len(key) == 4 and key not in get_known_fields('ID3V2'):
                add_field('ID3V2', key)

        id3_data['version'] = document.version

        for key in id3_data:
            data[key] = id3_data[key]

class MutagenOggVorbis(Mutagen):
    def __init__(self):
        super(MutagenOggVorbis, self).__init__('mutagen-oggvorbis', 'ogg')

    def read_tags(self, asset, data):
        ogg_data = {}
        document = OggVorbis(asset.absolute_path)
        for tag in document.tags:
            if tag[0] not in get_known_fields('ogg'):
                add_field('ogg', tag[0])

            key = tag[0]
            value = tag[1]
            ogg_data[key] = value
    

# class ImageHandler(FileHandler):
#     def __init__(self):
#         super(ImageHandler, self).__init__('mildred-img', get_supported_image_types())
#
#     def handle_file(self, asset, data):
#         pass


class GenericText(FileHandler):
    def __init__(self):
        super(GenericText, self).__init__('mildred-txt', 'txt', 'java', 'c', 'cpp', 'xml', 'html')

    def handle_file(self, asset, data):
        pass



class DelimitedText(GenericText):
    def __init__(self, DELIM_char=DELIM):
        super(GenericText, self).__init__('mildred-delimited', 'csv')
        self.DELIM = DELIM_char

    def handle_file(self, asset, data):
        pass
