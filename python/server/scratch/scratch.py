import sys, os

# ss

# doc = "The doc_name property."
# def fget(self):
#     return self._doc_name
# def fset(self, value):
#     self._doc_name = value
# def fdel(self):
#     del self._doc_name
# return locals()
# doc_name = property(**doc_name()))

# ensured paths

# def ensure(asset_type, esid, path):
#     esidforpath = get_cached_esid(asset_type, path)
#     if esidforpath is None:
#         key = DELIM.join(['ensure', esid])
#         values = { 'asset_type': asset_type, 'absolute_path': path, 'esid': esid }
#         config.redis.hmset(key, values)
#
#
# def flush_keys(keys):
#     for key in keys:
#         try:
#             values = config.redis.hgetall(key)
#             config.redis.delete(key)
#             # config.redis.hdel(key, 'esid', 'absolute_value', '')
#         except Exception, err:
#             print err.message
#
#
# def write_paths(flushkeys=True):
#
#     search = 'ensure-*'
#     keys = []
#     esids = []
#     for key in config.redis.scan_iter(search):
#         values = config.redis.hgetall(key)
#         keys.append(key)
#         if 'absolute_path' in values:
#             doc = config.redis.hgetall(values['absolute_path'])
#             if 'esid' not in doc:
#                 esids.append(values)
#
#         if len(esids) >= config.path_cache_size:
#             LOG.debug('clearing cached paths...')
#
#             # esids = []
#             paths = [{ 'esid': value['esid'], 'absolute_path': value['absolute_path'],
#                         'index_name': value['index_name'], 'asset_type': value['asset_type'] }
#                      for value in esids]
#
#             clause = ', '.join([sql.quote_if_string(value['esid']) for value in paths])
#             if clause != '':
#                 # q = """SELECT id FROM asset WHERE index_name ="%s" AND id in (%s)""" % (config.es_index, clause)
#                 # rows = sql.run_query(q)
#                 rows = sql.run_query_template('doc_select_esid_in', config.es_index, clause)
#                 if len(rows) != len(paths):
#                     cached_paths = [row[0] for row in rows]
#                     for path in paths:
#                         if path['esid'] not in cached_paths:
#                             # if config.sql_debug: print('Updating MySQL...')
#                             try:
#                                 assets.insert_asset(path['asset_type'], path['esid'], path['absolute_path'])
#                             except Exception, e:
#                                 print e.message
#
#     if flushkeys: flush_keys(keys)


def test_func():
    print('tests')

def main():
    # index = 'media'
    # rows = sql.retrieve_values('asset', ['id', 'absolute_path', 'asset_type'], [])
    # for row in rows:
    #     id = row[0]
    #     path = row[1]
    #     asset_type = row[2]
    #     hex = path.encode('hex')
    #     try:
    #         sql.insert_values('asset2', ['id', 'index_name', 'asset_type', 'absolute_path', 'hex_key'], [id, index, asset_type, path, hex])
    #     except Exception, err:
    #         print err.message

    # rows = sql.retrieve_values('op_record', ['id', 'target_path'], [])
    # for row in rows:
    #     id = int(row[0])
    #     key = row[1].encode('hex')
    #     try:
    #         query = 'update op_record set target_hex_key = "%s" where id = %i' % (key, id)
    #         print query
    #         sql.execute_query(query)
    #     except Exception, err:
    #         raise err
    pass

if __name__ == '__main__':
    main()