#!/usr/bin/python

import json
import logging
import os
import sys
import traceback

from elasticsearch.exceptions import ConnectionError

import cache, cache2
import config
import pathutil
import search
import sql
from assets import MediaFolder, MediaFile
import search

LOG = logging.getLogger('console.log')

KEY_PREFIX = 'library'
PATH_IN_DB = 'lib_path_in_db'

# cache functions

def get_cache_key():
    key = cache2.get_key(KEY_PREFIX, str(config.pid))
    if key is None:
        key = cache2.create_key(KEY_PREFIX, str(config.pid))

    return key


# directory cache

def cache_folder(folder):
    cache2.set_hash(KEY_PREFIX, get_cache_key(), { 'esid': folder.esid, 'absolute_path': folder.absolute_path, 'doc_type': config.MEDIA_FOLDER })


def clear_folder_cache():
    cache2.delete_hash(KEY_PREFIX, get_cache_key())


def get_cached_folder():
    values = cache2.get_hash(KEY_PREFIX, get_cache_key())
    if len(values) is 0: return None

    result = MediaFolder()
    result.esid = values['esid']
    result.absolute_path = values['absolute_path']
    result.document_type = values['doc_type']

    return result


# def get_latest_operation(self, path):
#
#     folder = MediaFolder()
#     folder.absolute_path = path
#
#     doc = search.get_doc(folder)
#     if doc is not None:
#         latest_operation = doc['_source']['latest_operation']
#         return latest_operation

# def record_error(self, folder, error):
#     try:
#         if folder is not None and error is not None:
#             self.folder.latest_error = error
#             if config.library_debug: print("recording error: " + error + ", " + folder.esid + ", " + folder.absolute_path)
#             res = config.es.update(index=config.es_index, doc_type=self.document_type, id=folder.esid, body={"doc": {"latest_error": error, "has_errors": True }})
#     except ConnectionError, err:
#         print ': '.join([err.__class__.__name__, err.message])
#         # if config.library_debug:
#         traceback.print_exc(file=sys.stdout)
#         print '\nConnection lost, please verify network connectivity and restart.'
#         sys.exit(1)


def sync_active_folder_state(folder):
    LOG.info('syncing metadata for %s' % folder.absolute_path)
    if search.unique_doc_exists(config.MEDIA_FOLDER, 'absolute_path', folder.absolute_path):
        folder.esid = search.unique_doc_id(config.MEDIA_FOLDER, 'absolute_path', folder.absolute_path)
    else:
        LOG.info('indexing %s' % folder.absolute_path)
        json_str = json.dumps(folder.get_dictionary())

        res = config.es.index(index=config.es_index, doc_type=folder.document_type, body=json_str)
        if res['_shards']['successful'] == 1:
            # if config.library_debug: print 'data indexed, updating MySQL'
            folder.esid = res['_id']
            # update MySQL
            # alchemy.insert_asset(config.es_index, folder.document_type, folder.esid, folder.absolute_path)
            insert_esid(config.es_index, folder.document_type, folder.esid, folder.absolute_path)
        else:
            raise Exception('Failed to write folder %s to Elasticsearch.' % folder.absolute_path)

    cache_folder(folder)

def set_active(path):

    # if path is None:
    #     self.folder = None
    #     return False

    # if self.folder is not None and self.folder.absolute_path == path: return False

    try:
        LOG.info('setting folder active: %s' % (path))
        folder = MediaFolder()
        folder.absolute_path = path
        folder.document_type = config.MEDIA_FOLDER
        sync_active_folder_state(folder)

    except ConnectionError, err:
        print ': '.join([err.__class__.__name__, err.message])
        # if config.library_debug:
        traceback.print_exc(file=sys.stdout)
        print '\nConnection lost, please verify network connectivity and restart.'
        sys.exit(1)

    return True


def doc_exists_for_path(doc_type, path):
    # check cache, cache will query db if esid not found in cache
    esid = cache.retrieve_esid(doc_type, path)
    if esid is not None: return True

    # esid not found in cache or db, search es
    return search.unique_doc_exists(doc_type, 'absolute_path', path)


def get_library_location(path):

    LOG.debug("determining location for %s." % (path.split('/')[-1]))

    for location in pathutil.get_locations():
        if location in path:
            return location

    for location in pathutil.get_locations_ext():
        if location in path:
            return location


def get_media_object(absolute_path, esid=None, check_cache=False, check_db=False, attach_doc=False, fail_on_fs_missing=False):
    """return a media file instance"""

    fs_avail = os.path.isfile(absolute_path) and os.access(absolute_path, os.R_OK)
    if fail_on_fs_missing and not fs_avail:
        LOG.warning("Either file is missing or is not readable")
        return None

    media = MediaFile()
    filename = os.path.split(absolute_path)[1]
    extension = os.path.splitext(absolute_path)[1]
    filename = filename.replace(extension, '')
    extension = extension.replace('.', '')

    media.esid = esid
    media.absolute_path = absolute_path
    media.file_name = filename
    media.location = get_library_location(absolute_path)
    media.ext = extension
    media.folder_name = os.path.abspath(os.path.join(absolute_path, os.pardir))
    media.file_size = os.path.getsize(absolute_path) if fs_avail else None

    if media.esid is None and check_cache:
        # check cache for esid
        if path_in_cache(media.document_type, absolute_path):
            media.esid = cache.get_cached_esid(media.document_type, absolute_path)

    if media.esid is None and check_db:
        if path_in_db(media.document_type, absolute_path):
            media.esid = retrieve_esid(media.document_type, absolute_path)

    if media.esid and attach_doc:
        try:
            media.doc = search.get_doc(media.document_type, media.esid)
        except Exception, err:
            LOG.warning(err.message)

    return media


def handle_asset_exception(error, path):
    if error.message.lower().startswith('multiple'):
        for item in  error.data:
            sql.insert_values('problem_esid', ['index_name', 'document_type', 'esid', 'problem_description'], [item[0], item[1], item[3], error.message])
    # elif error.message.lower().startswith('unable'):
    # elif error.message.lower().startswith('NO DOCUMENT'):
    else:
        sql.insert_values('problem_esid', ['index_name', 'document_type', 'esid', 'problem_description'], \
            [config.es_index, error.data.document_type, error.data.esid, error.message])


def insert_esid(index, document_type, elasticsearch_id, absolute_path):
    sql.insert_values('es_document', ['index_name', 'doc_type', 'id', 'absolute_path'],
        [index, document_type, elasticsearch_id, absolute_path])


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


# TODO: figure out why this fails
# def add_artist_and_album_to_db(self, data):

#     if 'TPE1' in data and 'TALB' in data:
#         try:
#             artist = data['TPE1'].lower()
#             rows = sql.retrieve_values('artist', ['name', 'id'], [artist])
#             if len(rows) == 0:
#                 try:
#                     print 'adding %s to MySQL...' % (artist)
#                     thread.start_new_thread( sql.insert_values, ( 'artist', ['name'], [artist], ) )
#                 except Exception, err:
#                     print ': '.join([err.__class__.__name__, err.message])
#                     if self.debug: traceback.print_exc(file=sys.stdout)

#             # sql.insert_values('artist', ['name'], [artist])
#             #     rows = sql.retrieve_values('artist', ['name', 'id'], [artist])
#             #
#             # artistid = rows[0][1]
#             #
#             # if 'TALB' in data:
#             #     album = data['TALB'].lower()
#             #     rows2 = sql.retrieve_values('album', ['name', 'artist_id', 'id'], [album, artistid])
#             #     if len(rows2) == 0:
#             #         sql.insert_values('album', ['name', 'artist_id'], [album, artistid])

#         except Exception, err:
#             print ': '.join([err.__class__.__name__, err.message])
#             if self.debug: traceback.print_exc(file=sys.stdout)


# exception handlers: these handlers, for the most part, simply log the error in the database for the system to repair on its own later



# this will be eliminated soon
# def doc_exists(asset, attach_if_found):
#     # look in local MySQL
#     esid_in_mysql = False
#     esid = cache.retrieve_esid(asset.document_type, asset.absolute_path)
#     if esid is not None:
#         esid_in_mysql = True
#         LOG.info("found esid %s for '%s' in sql." % (esid, asset.short_name()))
#
#         if attach_if_found and asset.esid is None:
#             LOG.info("attaching esid %s to ''%s'." % (esid, asset.short_name()))
#             asset.esid = esid
#
#         if attach_if_found == False: return True
#
#     if esid_in_mysql:
#         try:
#             doc = config.es.get(index=config.es_index, doc_type=asset.document_type, id=asset.esid)
#             asset.doc = doc
#             return True
#         except Exception, err:
#             LOG.error(err.message)
#             raise AssetException('DOC NOT FOUND FOR ESID:' + asset.to_str(), asset)
#
#     # not found, query elasticsearch
#     res = config.es.search(index=config.es_index, doc_type=asset.document_type, body={ "query": { "match" : { "absolute_path": asset.absolute_path }}})
#     for doc in res['hits']['hits']:
#         # if self.doc_refers_to(doc, media):
#         if doc['_source']['absolute_path'] == asset.absolute_path:
#             esid = doc['_id']
#             LOG.INFO("found esid %s for '%s' in Elasticsearch." % (esid, asset.short_name()))
#
#             if attach_if_found:
#                 asset.doc = doc
#                 if asset.esid is None:
#                     LOG.info("attaching esid %s to '%s'." % (esid, asset.short_name()))
#                     asset.esid = esid
#
#             if esid_in_mysql == False:
#                 # found, update local MySQL
#                 LOG.info('inserting esid into MySQL')
#                 try:
#                     # alchemy.insert_asset(config.es_index, asset.document_type, esid, asset.absolute_path)
#                     insert_esid(config.es_index, asset.document_type, asset.esid, asset.absolute_path)
#                     LOG.debug('esid inserted')
#                 except Exception, err:
#                     LOG.error(': '.join([err.__class__.__name__, err.message]))
#                     traceback.print_exc(file=sys.stdout)
#
#             return True
#
#     LOG.info('No document found for %s, %s, adding scan request to queue' % (asset.esid, asset.absolute_path))
#     rows = sql.retrieve_values('op_request', ['index_name', 'operation_name', 'target_path'], [config.es_index, 'scan', asset.absolute_path])
#     if rows == ():
#         sql.insert_values('op_request', ['index_name', 'operation_name', 'target_path'], [config.es_index, 'scan', asset.absolute_path])
#
#     return False
