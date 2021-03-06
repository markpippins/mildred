"""Cache2 is a wrapper around a subset of Redis, it provides support for complex keys as indexes for redis lists and key groups for other Redis types"""

import os
import logging

import util
import log

import redis

LOG = log.get_safe_log(__name__, logging.INFO)
ERR = log.get_safe_log('errors', logging.WARNING)

KEY = 'key'
DATA = 'data'
LIST = 'list'
HASH = 'hashset'
DELIM = ':'
WILDCARD = '*'
PID = str(os.getpid())

keystore = None
datastore = None
hashstore = None
liststore = None
orderedliststore = None

# these compound (key_group + identifier) keys occupy sorted lists, and are used as indexes for other sets of data
# identifier is an arbitrary list which will be separated by DELIM

# NOTE: in order for complex keys to truly work as indexes, the ordered set of values owned by them need to be used where these keys are currently being used

def str_clean4key(input):
    return util.str_clean4comp(input, DELIM, WILDCARD, '-', '_', '.')


def key_name(key_group, *identifier):
    """get a compound key name for a given identifier and a specified record type"""
    keyname = DELIM.join([key_group, identifier]) if isinstance(identifier, basestring) or isinstance(identifier, unicode) \
        else DELIM.join([key_group, DELIM.join(identifier)])

    result = str_clean4key(keyname)
    LOG.debug('key_name(key_group=%s, identifier=%s) returns %s', key_group, identifier, result)
    return result


def create_key(key_group, *identifier, **values):
    """create a new compound key"""
    key = key_name(key_group, *identifier)   
    result = keystore.rpush(key, None)

    for name in values:
        val = values[name]
        orderedliststore.rpush(key, val)

    LOG.debug('create_key(key_group=%s, identifier=%s) returns %s' % (key, identifier, result))
    return key


# def delete_key(key, delete_list=False, delete_hash=False):
def delete_key(key):
    result = keystore.delete(key)
   
    # remove hash values for key (delete_hash2)
    identifier = DELIM.join([HASH, key])
    hkeys = hashstore.hkeys(identifier)
    for hkey in hkeys:
        hashstore.hdel(identifier, hkey)

    # remove list values for key (clear_items2)
    identifier = DELIM.join([LIST, key])
    values = liststore.smembers(identifier)
    for value in values:
        result = liststore.srem(identifier, value)

    while lpeek2(key):
        lpop2(key)

    while rpeek2(key):
        rpop2(key)

    LOG.debug('datastore.delete(key=%s) returns: %s' % (key, str(result)))


def delete_key_group(key_group):
    LOG.debug('delete_key_group(key_group=%s)' % key_group)
    search = key_group + WILDCARD
    for key in keystore.keys(search):
        delete_key(key)


def delete_keys(key_group, *identifier):
    for key in get_keys(key_group, *identifier):
        delete_key(key)


def get_key(key_group, *identifier):
    result = get_keys(key_group, *identifier)
    LOG.debug('get_keys(key_group=%s, identifier=%s) returns %s' % (key_group, identifier, result))
    if len(result) is 1:
        return result[0]
    # (else)
    return create_key(key_group, *identifier)


def get_keys(key_group, *identifier):
    search = key_group + WILDCARD if identifier is () else key_name(key_group, *identifier) + WILDCARD
    result = keystore.keys(str_clean4key(search))
    # result = config.datastore.scan(str_clean4key(search), 0, -1)
    LOG.debug('get_keys(key_group=%s, identifier=%s) returns %s' % (key_group, identifier, result))
    return result


def key_exists(key_group, *identifier):
     key = key_name(key_group, *identifier)
     return keystore.exists(key)


def key_exists2(key):
    return keystore.exists(key)


# ordered list functions for compound keys and key groups

def lpeek(key_group, *identifier):
    key = key_name(key_group, *identifier)
    return lpeek2(key)


def lpeek2(key):
    if orderedliststore.llen(key) > 0:
        result = orderedliststore.lrange(key, 0, 0)
        return result[0]


def lpop(key_group, *identifier):
    key = key_name(key_group, *identifier)
    lpop2(key)


def lpop2(key):
    if orderedliststore.llen(key) > 0:
        return orderedliststore.lpop(key)


# def lpush(key_group, *identifier, **value):
#     key = key_name(key_group, *identifier)
#     for val in value:
#         config.datastore.lpush(key, value[val])


def lpush(key, *values):
    for val in values:
        orderedliststore.lpush(key, val)


def rpeek(key_group, *identifier):
    key = key_name(key_group, *identifier)
    return rpeek2(key)


def rpeek2(key):
    if orderedliststore.llen(key) > 0:
        result = orderedliststore.lrange(key, -1, -1)
        return result[0]


def rpop(key_group, *identifier):
    key = key_name(key_group, *identifier)
    rpop2(key)


def rpop2(key):
    if orderedliststore.llen(key) > 0:
        return orderedliststore.rpop(key)

# def rpush(key_group, *identifier, **value):
#     key = key_name(key_group, *identifier)
#     for val in value:
#         config.datastore.rpush(key, value[val])


def rpush(key, *values):
    for val in values:
        orderedliststore.rpush(key, val)


# hashsets

def delete_hash(key_group, identifier):
    key = DELIM.join([HASH, key_group, identifier])
    hkeys = hashstore.hkeys(key)
    for hkey in hkeys:
        hashstore.hdel(key, hkey)


def delete_hash2(key):
    identifier = DELIM.join([HASH, key])
    hkeys = hashstore.hkeys(identifier)
    for hkey in hkeys:
        hashstore.hdel(identifier, hkey)


def get_hash(key_group, identifier):
    key = DELIM.join([HASH, key_group, identifier])
    result = hashstore.hgetall(key)
    LOG.debug('get_hash(key_group=%s, identifier=%s) returns %s' % (key_group, identifier, result))
    return result


def get_hash2(key):
    identifier = DELIM.join([HASH, key])
    result = hashstore.hgetall(identifier)
    LOG.debug('get_hash2(key=%s) returns %s' % (key, result))
    return result


def get_hashes(key_group, *identifier):
    result = ()
    if identifier is ():
        for key in get_keys(DELIM.join([HASH, key_group])):
            ahash = hashstore.hgetall(key)
            if ahash is not None:
                result += (ahash,)
    #(else)
    for keyname in identifier:
        key = DELIM.join([HASH, key_group, keyname])
        ahash = hashstore.hgetall(key)
        if ahash is not None:
            result += (ahash,)

    LOG.debug('get_hashes(key_group=%s, identifier=%s) returns %s' % (key_group, identifier, result))
    return result


def set_hash(key_group, identifier, values):
    key = DELIM.join([HASH, key_group, identifier])
    if len(values) > 0:
        result = hashstore.hmset(key, values)
        LOG.debug('set_hash(key_group=%s, identifier=%s, values=%s) returns: %s' % (key_group, identifier, values, str(result)))


def set_hash2(key, values):
    identifier = DELIM.join([HASH, key])
    delete_hash2(key)
    if len(values) > 0:
        result = hashstore.hmset(identifier, values)
        LOG.debug('set_hash2(key=%s, values=%s) returns: %s' % (key, values, str(result)))

# lists

def add_item(key_group, identifier, item):
    key = DELIM.join([LIST, key_group, identifier])
    result = liststore.sadd(key, item)
    LOG.debug('add_item(key_group=%s, identifier=%s, item=%s) returns: %s' % (key_group, identifier, item, str(result)))


def add_item2(key, item):
    key = DELIM.join([LIST, key])
    result = liststore.sadd(key, item)
    LOG.debug('add_item(key=%s,item=%s) returns: %s' % (key, item, str(result)))


def add_items(key_group, identifier, items):
    for item in items:
        add_item(key_group, identifier, item)
        # key = DELIM.join([LIST, key_group, identifier])
        # result = config.datastore.sadd(key, item)
        # LOG.debug('add_item(key_group=%s, identifier=%s, item=%s) returns: %s' % (key_group, identifier, item, str(result)))


def add_items2(key, items):
    key = DELIM.join([LIST, key])
    for item in items:
        result = liststore.sadd(key, item)
        LOG.debug('add_item2(key=%s, item=%s) returns: %s' % (key, item, str(result)))


def clear_items(key_group, identifier):
    key = DELIM.join([LIST, key_group, identifier])
    values = liststore.smembers(key)
    for value in values:
        result = liststore.srem(key, value)
        LOG.debug('datastore.srem(key_group=%s, identifier=%s) returns: %s' % (key, value, str(result)))


def clear_items2(key):
    key = DELIM.join([LIST, key])
    values = liststore.smembers(key)
    for value in values:
        result = liststore.srem(key, value)
        LOG.debug('datastore.srem(key_group=%s, identifier=%s) returns: %s' % (key, value, str(result)))


def get_items(key_group, identifier):
    key = DELIM.join([LIST, key_group, identifier])
    result = liststore.smembers(key)
    LOG.debug('get_items(key_group=%s, identifier=%s) returns: %s' % (key_group, identifier, str(result)))
    return result


def get_items2(key):
    key = DELIM.join([LIST, key])
    result = liststore.smembers(key)
    LOG.debug('get_items(key=%s) returns: %s' % (key, str(result)))
    return result


# lists of hashsets
# These hashsets differ from the hashes handled by set_hash, set_hash2, get_hash, get_hash2, etc. in that they are \
# intended to be owned by a compound key and are removed when that key is deleted

def add_hashset(keyname, set_identifier, hashset):

    key = get_key(keyname, set_identifier)
    hlkey = DELIM.join([LIST, HASH, key])

    count = len(get_items2(hlkey))
    keyinlist = DELIM.join([key, str(count)])

    set_hash2(keyinlist, hashset)
    add_item2(hlkey, keyinlist)


def clear_hashsets(keyname, set_identifier):
    key = get_key(keyname, set_identifier)
    hlkey = DELIM.join([LIST, HASH, key])

    count = len(get_items2(hlkey))
    for index in range(count):
        keyinlist = DELIM.join([key, str(index)])
        delete_hash2(keyinlist)

    clear_items2(hlkey)


def get_hashsets(keyname, set_identifier):
    result = []

    key = get_key(keyname, set_identifier)
    hlkey = DELIM.join([LIST, HASH, key])
    count = len(get_items2(hlkey))

    for index in range(count):
        keyinlist = DELIM.join([key, str(index)])
        ahash = get_hash2(keyinlist)
        result.append(ahash)

    return result


# utility

def flush_all():
    LOG.info('flushing redis database')
    keystore.flushdb()
    datastore.flushdb()
    hashstore.flushdb()
    liststore.flushdb()
    orderedliststore.flushdb()
    