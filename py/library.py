#!/usr/bin/python

import json
import logging
import os
import sys
import traceback

from elasticsearch.exceptions import ConnectionError

import alchemy

import cache, cache2
import config
import pathutil
import search
import sql
from assets import Directory, Document
from errors import AssetException
import search

LOG = logging.getLogger('console.log')

KEY_GROUP = 'library'
PATH_IN_DB = 'lib_path_in_db'

# cache functions

def get_cache_key():
    key = cache2.get_key(KEY_GROUP, str(config.pid))
    if key is None:
        key = cache2.create_key(KEY_GROUP, str(config.pid))
    return key


# directory cache

def cache_directory(directory):
    if directory is None:
        cache2.set_hash2(get_cache_key(), { 'active:': None })
    else:
        cache2.set_hash2(get_cache_key(), directory.to_dictionary())


def clear_directory_cache():
    cache2.delete_hash2(get_cache_key())


def get_cached_directory():
    values = cache2.get_hash2(get_cache_key())
    if len(values) is 0: return None
    if not 'esid' in values and not 'absolute_path' in values:
        return None

    result = Directory()
    result.esid = values['esid']
    result.absolute_path = values['absolute_path']
    result.document_type = values['document_type']

    return result


# def get_latest_operation(self, path):
#
#     directory = Directory()
#     directory.absolute_path = path
#
#     doc = search.get_doc(directory)
#     if doc is not None:
#         latest_operation = doc['_source']['latest_operation']
#         return latest_operation

def record_error(self, directory, error):
    # try:
    if directory is not None and error is not None:
        LOG.info("recording error: " + error + ", " + directory.esid + ", " + directory.absolute_path)
        dir_vals = cache2.get_hash2(get_cache_key())
        dir_vals['latest_error'] = error.__class__

            # res = config.es.update(index=config.es_index, doc_type=self.document_type, id=directory.esid, body={"doc": {"latest_error": error, "has_errors": True }})
    # except ConnectionError, err:
    #     print ': '.join([err.__class__.__name__, err.message])
    #     # if config.library_debug:
    #     traceback.print_exc(file=sys.stdout)
    #     print '\nConnection lost, please verify network connectivity and restart.'
    #     sys.exit(1)

def record_file_read(self, reader_name, directory, media):
        if directory is not None:
            file_data = { '_reader': reader_name, '_file_name': media.file_name }
            dir_vals = cache2.get_hash2(get_cache_key())
            dir_vals['read_files'].append(file_data)

def sync_active_directory_state(directory):
    if directory is not None:
        LOG.debug('syncing metadata for %s' % directory.absolute_path)
        if search.unique_doc_exists(config.DIRECTORY, 'absolute_path', directory.absolute_path):
            directory.esid = search.unique_doc_id(config.DIRECTORY, 'absolute_path', directory.absolute_path)

            # TODO: resolve this cart before horse issue right here
            # dir_vals = cache2.get_hash2(get_cache_key())
            # if len (dir_vals['data.read_files']) > 0:
            #     try:
            #         res = config.es.update(index=config.es_index, doc_type=self.document_type, id=directory.esid, body= json.dumps(dir_vals))
            #     except ConnectionError, err:
            #         print ': '.join([err.__class__.__name__, err.message])
            #         # if config.library_debug:
            #         traceback.print_exc(file=sys.stdout)
            #         print '\nConnection lost, please verify network connectivity and restart.'
            #         sys.exit(1)

        else:
            LOG.debug('indexing %s' % directory.absolute_path)
            json_str = json.dumps(directory.to_dictionary())
            # TODO:elasticsearch.exceptions.ConnectionTimeout, ConnectionTimeout caused by - ReadTimeoutError(HTTPConnectionPool(host='localhost', port=9200): Read timed out. (read timeout=10))

            res = config.es.index(index=config.es_index, doc_type=directory.document_type, body=json_str)
            if res['_shards']['successful'] == 1:
                LOG.debug('data indexed, updating MariaDB')
                directory.esid = res['_id']
                # update MariaDB
                try:
                    insert_asset(config.es_index, directory.document_type, directory.esid, directory.absolute_path)
                except Exception, err:
                    if directory.esid is not None:
                        config.es.delete(config.es_index, directory.document_type, directory.esid)
                    raise err
            else:
                raise Exception('Failed to write directory %s to Elasticsearch.' % directory.absolute_path)

    cache_directory(directory)


def set_active(path):

    if path is None:
        sync_active_directory_state(None)
        return

    try:
        directory = Directory()
        directory.absolute_path = path
        directory.document_type = config.DIRECTORY
        sync_active_directory_state(directory)
	return True
    except ConnectionError, err:
        print ': '.join([err.__class__.__name__, err.message])
        # if config.library_debug:
        traceback.print_exc(file=sys.stdout)
        print '\nConnection lost, please verify network connectivity and restart.'
        sys.exit(1)


def doc_exists_for_path(doc_type, path):
    # check cache, cache will query db if esid not found in cache
    esid = cache.retrieve_esid(doc_type, path)
    if esid is not None: return True

    # esid not found in cache or db, search es
    return search.unique_doc_exists(doc_type, 'absolute_path', path)


def get_library_location(path):
    # LOG.debug("determining location for %s." % (path.split(os.path.sep)[-1]))
    possible = []

    for location in pathutil.get_locations():
        if location in path:
	    possible.append(location)
    
    if len(possible) == 1:
	return possible[0]
      
    if len(possible) > 1:
      result = possible[0]
      for item in possible:
	if len(item) > len(result):
	  result = item

      return result


def get_media_object(absolute_path, esid=None, check_cache=False, check_db=False, attach_doc=False, fail_on_fs_missing=False):
    """return a media file instance"""
    fs_avail = os.path.isfile(absolute_path) and os.access(absolute_path, os.R_OK)
    if fail_on_fs_missing and not fs_avail:
        LOG.warning("File %s is missing or is not readable" % absolute_path)
        return None
    

    media = Document()
    filename = os.path.split(absolute_path)[1]
    extension = os.path.splitext(absolute_path)[1]
    filename = filename.replace(extension, '')
    extension = extension.replace('.', '')

    media.esid = esid
    media.absolute_path = absolute_path
    media.file_name = filename
    media.location = get_library_location(absolute_path)
    media.ext = extension

    media.available = fs_avail
    if media.available:
        media.directory_name = os.path.abspath(os.path.join(absolute_path, os.pardir)) if fs_avail else None
        media.file_size = os.path.getsize(absolute_path) if fs_avail else None

    # check cache for esid
    if media.esid is None and check_cache and path_in_cache(media.document_type, absolute_path):
        media.esid = cache.get_cached_esid(media.document_type, absolute_path)

    if media.esid is None and check_db and path_in_db(media.document_type, absolute_path):
        media.esid = retrieve_esid(media.document_type, absolute_path)

    if media.esid and attach_doc:
        media.doc = search.get_doc(media.document_type, media.esid)

    return media


def insert_asset(index_name, document_type, elasticsearch_id, absolute_path):
    alchemy.insert_asset(index_name, document_type, elasticsearch_id, absolute_path)


def path_in_cache(document_type, path):
    return cache.get_cached_esid(document_type, path)


def path_in_db(document_type, path):
    return len(sql.run_query_template(PATH_IN_DB, config.es_index, document_type, path)) is 1


def retrieve_esid(document_type, absolute_path):
    rows = sql.retrieve_values('es_document', ['index_name', 'doc_type', 'absolute_path', 'id'], [config.es_index, document_type, absolute_path])
    # rows = sql.run_query("select index_name, doc_type, absolute_path")
    if len(rows) == 0: return None
    if len(rows) == 1: return rows[0][3]
    elif len(rows) >1: raise AssetException("Multiple Ids for '" + absolute_path + "' returned", rows)


# exception handlers: these handlers, for the most part, simply log the error in the database for the system to repair on its own later

def handle_asset_exception(error, path):
    if error.message.lower().startswith('multiple'):
        for item in  error.data:
            sql.insert_values('problem_esid', ['index_name', 'document_type', 'esid', 'problem_description'], [item[0], item[1], item[3], error.message])
    # elif error.message.lower().startswith('unable'):
    # elif error.message.lower().startswith('NO DOCUMENT'):
    else:
        sql.insert_values('problem_esid', ['index_name', 'document_type', 'esid', 'problem_description'], \
            [config.es_index, error.data.document_type, error.data.esid, error.message])



