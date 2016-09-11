import os, sys, traceback

import config, operations, mySQLintf, esutil
from matcher import ElasticSearchMatcher
from scanner import Param
from asset import Asset, MediaFile, MediaFolder, AssetException
import redis

def all_matchers_have_run(matchers, media):
    skip_entirely = True
    paths = []
    for matcher in matchers:
        if not operations.operation_in_cache(media.absolute_path, 'match', matcher.name):
            skip_entirely = False
            break

    return skip_entirely
    
def path_exists_in_data(path):
    path = path.replace('"', "'")
    path = path.replace("'", "\'")
    q = 'select * from es_document where index_name = "%s" and doc_type = "%s" and absolute_path like "%s%s" limit 1' % \
        (config.es_index, config.MEDIA_FOLDER, path, '%')
    rows = mySQLintf.run_query(q)
    if len(rows) == 1:
        return True

def calculate_matches(matchers, param, pid):

    opcount = 0
    # self.active_param = param
    for location in param.locations:            
        if path_exists_in_data(location):
            try:
                location += '/'
                if config.CHECK_FOR_BUGS: raw_input('check for bugs')
                # match_ops = self.retrieve_completed_match_ops(location)

                operations.cache_doc_info(config.MEDIA_FILE, location)
                
                print 'caching match ops for %s...' % (location)
                for matcher in matchers:
                    operations.cache_operations_for_path(location, 'match', matcher.name)

                print 'caching matches for %s...' % (location)
                operations.cache_match_info(location)
                
                for key in operations.get_keys(config.MEDIA_FILE):
                    if not location in key:
                        print 'skipping %s' % (key)
                    values = config.redis.hgetall(key)
                    if not 'esid' in values:
                        continue
                        
                    # opcount += 1
                    # if opcount % config.CHECK_FREQUENCY == 0:
                    #     self.check_for_stop_request()
                    #     self.check_for_reconfig_request()

                    media = MediaFile()
                    media.absolute_path = key
                    media.esid = values['esid']
                    media.document_type = config.MEDIA_FILE

                    try:
                        if all_matchers_have_run(matchers, media):
                            # if self.debug: 
                            print 'skipping all match operations on %s, %s' % (media.esid, media.absolute_path)
                            continue

                        if esutil.doc_exists(media, True):
                            for matcher in matchers:
                                if not operations.operation_in_cache(media.absolute_path, 'match', matcher.name):
                                    # if self.debug: 
                                    print '\n%s seeking matches for %s' % (matcher.name, media.absolute_path)

                                    operations.record_op_begin(self.self.pid, media, matcher.name, 'match')
                                    matcher.match(media)
                                    operations.record_op_complete(self.self.pid, media, matcher.name, 'match')
                                # elif self.debug: 
                                else: print 'skipping %s operation on %s' % (matcher.name, media.absolute_path)
                    
                    except AssetException, err:
                        # self.folderman.record_error(self.folderman.folder, "AssetException=" + err.message)
                        print ': '.join([err.__class__.__name__, err.message])
                        # if self.debug: traceback.print_exc(file=sys.stdout)
                        operations.handle_asset_exception(err, media.absolute_path)
                    
                    except UnicodeDecodeError, u:
                        # self.folderman.record_error(self.folderman.folder, "UnicodeDecodeError=" + u.message)
                        print ': '.join([u.__class__.__name__, u.message, media.absolute_path])

                    except Exception, u:
                        # self.folderman.record_error(self.folderman.folder, "UnicodeDecodeError=" + u.message)
                        print ': '.join([u.__class__.__name__, u.message, media.absolute_path])

                    finally:
                        for matcher in matchers:
                            operations.clear_cached_matches_for_esid(matcher.name, media.esid)
        
            except Exception, err:
                print ': '.join([err.__class__.__name__, err.message, location])
                # if self.debug: 
                traceback.print_exc(file=sys.stdout)
            finally:
                # self.folderman.folder = None
                operations.write_ensured_paths()
                for matcher in matchers:
                    operations.write_ops_for_path(pid, location, matcher.name, 'match')
                operations.clear_cache_operations_for_path(location, True)
                operations.clear_cached_doc_info(config.MEDIA_FILE, location) 
            

    print '\n-----match operations complete-----\n'
    
def record_match_ops_complete(matcher, media, path, pid):
    try:
        operations.record_op_complete(self.pid, media, matcher.name, 'match')
        if operations.operation_completed(media, matcher.name, 'match', pid) == False:
            raise AssetException('Unable to store/retrieve operation record', media)
    except AssetException, err:
        print ': '.join([err.__class__.__name__, err.message])
        # if self.debug: traceback.print_exc(file=sys.stdout)
        operations.handle_asset_exception(err, path)


def record_matches_as_ops(pid):

    rows = mySQLintf.retrieve_values('temp', ['media_doc_id', 'matcher_name', 'absolute_path'], [])
    for r in rows:
        media = MediaFile()
        matcher_name = r[1]
        media.esid = r[0]
        media.absolute_path = r[2]

        if operations.operation_completed(media, matcher_name, 'match') == False:
            operations.record_op_begin(pid, media, matcher_name, 'match')
            operations.record_op_complete(pid, media, matcher_name, 'match')
            print 'recorded(%i, %s, %s, %s)' % (pid, r[1], r[2], 'match')