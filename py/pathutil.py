import logging
import os

import  core.log
import sql
from core import cache2

LOG = core.log.get_log(__name__, logging.DEBUG)


def get_directory_constants(identifier):
    keygroup = 'directory_constants'
    if not cache2.key_exists(keygroup, identifier):
        key = cache2.create_key(keygroup, identifier)
        rows = sql.retrieve_values('directory_constant', ['location_type', 'pattern'], [identifier.lower()])
        for row in rows:
            cache2.add_item2(key, row[1])

    key = cache2.get_key(keygroup, identifier)
    return cache2.get_items2(key)


def get_items(keygroup, identifier):
    result = []
    result.extend(cache2.get_items(keygroup, identifier))
    result.sort()
    return result


def get_locations():
    keygroup = 'directory'
    identifier = 'location'
    if not cache2.key_exists(keygroup, identifier):
        key = cache2.create_key(keygroup, identifier)
        rows = sql.retrieve_values('directory', ['name'], [])
        cache2.add_items(keygroup, identifier, [row[0] for row in rows])

    return get_items(keygroup, identifier)


def get_excluded_locations():
    keygroup = 'directory'
    identifier = 'exclude'
    if not cache2.key_exists(keygroup, identifier):
        key = cache2.create_key(keygroup, identifier)
        rows = sql.retrieve_values('exclude_directory', ['name'], [])
        cache2.add_items(keygroup, identifier, [row[0] for row in rows])

    return get_items(keygroup, identifier)


def get_document_category_names():
    keygroup = 'document'
    identifier = 'category_names'
    if not cache2.key_exists(keygroup, identifier):
        key = cache2.create_key(keygroup, identifier)
        rows = sql.retrieve_values('document_category', ['name'], [])
        cache2.add_items(keygroup, identifier, [row[0] for row in rows])

    return get_items(keygroup, identifier)


def get_active_document_formats():
    keygroup = 'document'
    identifier = 'formats'
    if not cache2.key_exists(keygroup, identifier):
        key = cache2.create_key(keygroup, identifier)
        rows = sql.retrieve_values('document_format', ['active_flag', 'ext'], ['1'])
        cache2.add_items(keygroup, identifier, [row[1] for row in rows])

    return get_items(keygroup, identifier)


def is_curated(self, path):
    curated = get_directory_constants('curated')
    for pattern in curated:
        if path.endswith(pattern):
            return True

def is_expunged(path):
    directories = ['[expunged]']
    for f in directories:
        if f in path:
            return True

def is_filed(path):
    directories = ['/albums', '/compilations']
    for f in directories:
        if f in path:
            return True


def is_filed_as_compilation(path):
    return path in get_directory_constants('compilation')


def is_filed_as_live(path):
    return path in get_directory_constants('live_recordings')


def is_new(path):
    return path in get_directory_constants('new')


def is_noscan(path):
    directories = ['[noscan]']
    for f in directories:
        if f in path:
            return True


def is_random(path):
    return path in get_directory_constants('random')


def is_recent(path):
    return path in get_directory_constants('recent')


def is_unsorted(path):
    return path in get_directory_constants('unsorted')


def is_webcast(path):
    return False


def ignore(path):
    return path in get_directory_constants('ignore')


def path_contains_album_directories(path):
    raise Exception('not implemented!')


# TODO: Offline mode - query MariaDB and ES before looking at the file system
def path_contains_document_categories(path):
    raise Exception('not implemented!')


# TODO: Offline mode - query MariaDB and ES before looking at the file system
def file_type_recognized(path, extensions, recursive=False):
    # if self.debug: print path
    if os.path.isdir(path):
        for f in os.listdir(path):
            if os.path.isfile(os.path.join(path, f)):
                for ext in extensions:
                    if f.lower().endswith('.' + ext.lower()):
                        return True

    else: raise Exception('Path does not exist: "' + path + '"')


# TODO: Offline mode - query MariaDB and ES before looking at the file system
def multiple_file_types_recognized(path, extensions):
    # if self.debug: print path
    if os.path.isdir(path):

        found = []
        for f in os.listdir(path):
            if os.path.isfile(os.path.join(path, f)):
                for ext in extensions:
                    if f.lower().endswith('.' + ext):
                        if ext not in found:
                            found.append(ext)

        return len(found) > 1

    else: raise Exception('Path does not exist: "' + path + '"')


# TODO: Offline mode - query MariaDB and ES before looking at the file system
def path_has_location_name(path, names):
    # if path.endswith(os.path.sep):
    for name in get_locations():
        if path.endswith(name):
            return True

# TODO: Offline mode - query MariaDB and ES before looking at the file system
def path_in_album_directory(path):
    # if self.debug: print path
    if os.path.isdir(path) is False:
        raise Exception('Path does not exist: "' + path + '"')

    raise Exception('not implemented!')


# TODO: Offline mode - query MariaDB and ES before looking at the file system
def path_in_document_category(path):
    raise Exception('not implemented!')


# TODO: Offline mode - query MariaDB and ES before looking at the file system
def path_in_location_directory(path):
    raise Exception('not implemented!')


# TODO: Offline mode - query MariaDB and ES before looking at the file system
def path_is_album_directory(path):
    # if self.debug: print path
    if os.path.isdir(path) is False:
        raise Exception('Path does not exist: "' + path + '"')

    raise Exception('not implemented!')


# TODO: Offline mode - query MariaDB and ES before looking at the file system
def path_is_document_category(path):
    raise Exception('not implemented!')


# TODO: Offline mode - query MariaDB and ES before looking at the file system
def path_is_location_directory(path):
    raise Exception('not implemented!')
