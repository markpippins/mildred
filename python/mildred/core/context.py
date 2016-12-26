
import sys, os

import cache2

LOG = log.get_log(__name__, logging.DEBUG)
ERR = log.get_log('errors', logging.WARNING)

class Context(object):
    """context is a container for state that is accessible to different parts of a process or application"""
    def __init__(self, name):
        self.name = name

        # one per consumer
        self.fifos = {}
        self.stacks = {}
        self.params = {}

        # shared by all consumers
        self.data = {}

    def clear(self):
        self.data.clear()

        for consumer in self.fifos.keys:
            self.clear_fifo(consumer)

        for consumer in self.stacks.keys:
            self.clear_stack(consumer)

        for consumer in self.params.keys:
            self.clear_params(consumer)

    # cache

    def restore_from_cache(self):
        # context should be able to save and restore whatever portion of its data is not contained in object instances
        pass

    def save_to_cache(self):
        pass

    # FIFO

    def clear_fifo(self, consumer):
        if consumer in self.fifos:
            self.fifos.remove(consumer)

    def peek_fifo(self, consumer):
        if consumer in self.fifos and len(self.fifos[consumer]) > 0:
            return self.fifos[consumer][0]

    def pop_fifo(self, consumer):
        if consumer in self.fifos and len(self.fifos[consumer]) > 0:
            return self.fifos[consumer].pop(0)

    def push_fifo(self, consumer, value):
        if consumer not in self.fifos:
            self.fifos[consumer] = []
        self.fifos[consumer].insert(0, value)

    def rpush_fifo(self, consumer, value):
        if consumer not in self.fifos:
            self.fifos[consumer] = []
        self.fifos[consumer].append(value)

    # stack

    def clear_stack(self, consumer):
        if consumer in self.stacks:
            self.stacks.remove(consumer)

    def peek_stack(self, consumer):
        if consumer in self.stacks and len(self.stacks[consumer]) > 0:
            return self.stacks[consumer][-1]

    def pop_stack(self, consumer):
        if consumer in self.stacks and len(self.stacks[consumer]) > 0:
            return self.stacks[consumer].pop(0)

    def push_stack(self, consumer, value):
        if consumer not in self.stacks:
            self.stacks[consumer] = []
        self.stacks[consumer].append(value)


    # params

    def get_param(self, consumer, param):
        if consumer in self.params:
            # if param in self.params[consumer]:
            params = self.params[consumer]
            if param in params:
                return params[param]

    def get_params(self, consumer):
        if consumer in self.params:
            return self.params(consumer)

    def set_param(self, consumer, param, value):
        # print "setting %s[%s] to %s" % (str(consumer), param, str(value) )
        if consumer not in self.params:
            self.params[consumer] = {}
        self.params[consumer][param] = value


    def clear_params(self, consumer):
        if consumer in self.params:
            del self.params[consumer]


    def reset(self, consumer):
        self.clear_fifo(consumer)
        self.clear_stack(consumer)
        self.clear_params(consumer)


class DirectoryContext(Context):
    def __init__(self, name, paths, cycle=False):
        super(DirectoryContext, self).__init__(name)
        self.paths = paths
        self.consumer_paths = {}
        self.cycle = cycle
        self.always_peek_fifo = True

    def clear(self):
        super(DirectoryContext, self).clear()
        self.paths = []

    def clear_active(self, consumer):
        if consumer in self.consumer_paths:
            del(self.consumer_paths[consumer])

    def get_active(self, consumer):
        if consumer in self.consumer_paths:
            return self.consumer_paths[consumer]
        else:
            return self.get_next(consumer)

    def get_next(self, consumer, use_fifo=False):

        if (self.always_peek_fifo or use_fifo) and self.peek_fifo(consumer):
            return self.pop_fifo(consumer)

        if len(self.paths) == 0: return None

        result = None

        if consumer in self.consumer_paths:
            index = self.paths.index(self.consumer_paths[consumer]) + 1
            if len(self.paths) > index:
                result = self.paths[index]
                self.consumer_paths[consumer] = result
            elif self.cycle:
                result = self.paths[0]
                self.consumer_paths[consumer] = result
        else:
            result = self.paths[0]
            self.consumer_paths[consumer] = result

        return result

    def has_active(self, consumer):
        return consumer in self.consumer_paths

    def has_next(self, consumer, use_fifo=False):

        if (self.always_peek_fifo or use_fifo) and self.peek_fifo(consumer):
            return True

        if len(self.paths) == 0: return False

        result = False
        if consumer in self.consumer_paths:
            index = self.paths.index(self.consumer_paths[consumer]) + 1
            if len(self.paths) > index or self.cycle: result = True
        else: result = True

        return result

    def path_in_context(self, path):
        return path in self.paths

    def path_in_fifo(self, path, consumer):
        if consumer in self.fifos:
            return path in self.fifos[consumer]

    def peek_next(self, consumer, use_fifo=False):

        if (self.always_peek_fifo or use_fifo) and self.peek_fifo(consumer) is not None:
            return self.peek_fifo(consumer)

        if len(self.paths) == 0: return None

        if consumer in self.consumer_paths:
            index = self.paths.index(self.consumer_paths[consumer]) + 1
            if len(self.paths) > index:
                return self.paths[index]
        # elif cycle:
        else: return self.paths[0]

    def reset(self, consumer):
        super(DirectoryContext, self).reset(consumer)
        if consumer in self.consumer_paths:
            del(self.consumer_paths[consumer])


CDC = 'CachedDirectoryContext'

class CachedDirectoryContext(DirectoryContext):
    def __init__(self, name, paths, cycle=False):
        super(CachedDirectoryContext, self).__init__(name, paths, cycle)
        self.consumer_key = cache2.create_key(CDC, 'consumers')

    # def clear(self):
    #     super(CachedDirectoryContext, self).clear()

  # FIFO

    def clear_fifo(self, consumer):
        while self.peek_fifo(consumer) is not None:
            self.pop_fifo(consumer)

    def peek_fifo(self, consumer):
        key = cache2.get_key(CDC, consumer)
        value = cache2.lpeek2(key)
        if value == 'None':
            return None
        return value

    def pop_fifo(self, consumer):
        key = cache2.get_key(CDC, consumer)
        value = cache2.lpop2(key)
        if value == 'None':
            return None
        return value

    def push_fifo(self, consumer, value):
        key = cache2.get_key(CDC, consumer)
        cache2.lpush(key, value)

    def rpush_fifo(self, consumer, value):
        key = cache2.get_key(CDC, consumer)
        cache2.rpush(key, value)

    # Params

    def clear_params(self, consumer):
        key = cache2.get_key(CDC, consumer)
        cache2.delete_hash2(key)

    def get_param(self, consumer, param):
        key = cache2.get_key(CDC, consumer)
        values = cache2.get_hash2(key)
        if param in values:
            return values[param]

    def get_params(self, consumer):
        key = cache2.get_key(CDC, consumer)
        values = cache2.get_hash2(key)
        return values

    def set_param(self, consumer, param, value):
        key = cache2.get_key(CDC, consumer)
        values = cache2.get_hash2(key)
        values[param] = value
        cache2.set_hash2(key, values)

    # Path

    def clear_active(self, consumer):
        cached_consumer_paths = cache2.get_hash2(self.consumer_key)

        if consumer in cached_consumer_paths:
            del(cached_consumer_paths[consumer])

        cache2.set_hash2(self.consumer_key, cached_consumer_paths)

    def get_active(self, consumer):
        cached_consumer_paths = cache2.get_hash2(self.consumer_key)

        if consumer in cached_consumer_paths:
            return cached_consumer_paths[consumer]
        else:
            return self.get_next(consumer)

    def get_next(self, consumer, use_fifo=False):
        cached_consumer_paths = cache2.get_hash2(self.consumer_key)

        if (self.always_peek_fifo or use_fifo) and self.peek_fifo(consumer):
            return self.pop_fifo(consumer)

        if len(self.paths) == 0: return None

        result = None

        if consumer in cached_consumer_paths:
            index = self.paths.index(cached_consumer_paths[consumer]) + 1

            if len(self.paths) > index:
                result = self.paths[index]
                cached_consumer_paths[consumer] = result
            elif self.cycle:
                result = self.paths[0]
                cached_consumer_paths[consumer] = result
        else:
            result = self.paths[0]
            cached_consumer_paths[consumer] = result

        cache2.set_hash2(self.consumer_key, cached_consumer_paths)

        return result

    def has_active(self, consumer):
        cached_consumer_paths = cache2.get_hash2(self.consumer_key)
        return consumer in cached_consumer_paths

    def has_next(self, consumer, use_fifo=False):
        cached_consumer_paths = cache2.get_hash2(self.consumer_key)

        if (self.always_peek_fifo or use_fifo) and self.peek_fifo(consumer):
            return True

        if len(self.paths) == 0: return False

        result = False

        if consumer in cached_consumer_paths:
            index = self.paths.index(cached_consumer_paths[consumer]) + 1
            if len(self.paths) > index or self.cycle: result = True
        else: result = True

        return result

    # def path_in_fifo(self, path, consumer):
    #     cached_consumer_paths = cache2.get_hash2(self.consumer_key)
    #     if consumer in cached_consumer_paths:
    #         buffer = self.
    #     if consumer in self.fifos:
    #         return path in self.fifos[consumer]

    def peek_next(self, consumer, use_fifo=False):
        cached_consumer_paths = cache2.get_hash2(self.consumer_key)

        if (self.always_peek_fifo or use_fifo) and self.peek_fifo(consumer) is not None:
            return self.peek_fifo(consumer)

        if len(self.paths) == 0: return None

        if consumer in cached_consumer_paths:
            index = self.paths.index(cached_consumer_paths[consumer]) + 1
            if len(self.paths) > index:
                return self.paths[index]
        # elif cycle:
        else: return self.paths[0]

    def reset(self, consumer, use_fifo=False):
        super(CachedDirectoryContext, self).reset(consumer)
        self.clear_fifo(consumer)
        self.clear_params(consumer)

        cached_consumer_paths = cache2.get_hash2(self.consumer_key)

        if consumer in cached_consumer_paths:
            del(cached_consumer_paths[consumer])
            cache2.set_hash2(self.consumer_key, cached_consumer_paths)

PERSIST = 'scan.persist'
ACTIVE = 'active.scan.path'
SCAN = 'context.scan'

class DirectoryContextScanner(object):

    def __init__(self, directorycontext, get_locations_func, handle_context_path_func, handle_error_func=None, before=None, after=None):
        self.context = directorycontext
        self.get_locations_func = get_locations_func
        self.handle_context_path_func = handle_context_path_func
        self.handle_error_func = handle_error_func
        self.before = before
        self.after = after
        self.last_expanded_path = None

    def handle_error(self, error, path):
        if self.handle_error_func:
            self.handle_error_func(error, path)

    def handle_context_path(self, path):
        self.handle_context_path_func(path)

    def should_cache(self, path):
        return False

    def should_skip(self, path):
        return False

    def path_expands(self, path):
        expanded = False
        do_expand = False

        if path in self.get_locations_func():
            do_expand = True
        
        if path in self.context.paths:
            if self.context.get_param('all', 'expand_all'):
                do_expand = True
        
        if do_expand:
            # or pathutil.is_curated(path):
            dirs = os.listdir(path)
            dirs.sort(reverse=True)
            for dir in dirs:
                sub_path = os.path.join(path, dir)
                if os.path.isdir(path) and os.access(path, os.R_OK):
                    self.context.push_fifo(SCAN, sub_path)
                    expanded = True

        return expanded

    # TODO: individual paths in the directory context should have their own scan configuration

    def scan(self):
        # self.deep_scan = self.context.get_param(SCAN, DEEP)
        # self.high_scan = self.context.get_param(SCAN, HSCAN)
        # self.update_scan = self.context.get_param(SCAN, USCAN)

        path = self.context.get_param(PERSIST, ACTIVE)
        path_restored = path is not None
        self.last_expanded_path = None

        while self.context.has_next(SCAN, use_fifo=True):
            path = path if path_restored else self.context.get_next(SCAN, True)           
            path_restored = False
            self.context.set_param(PERSIST, ACTIVE, path)

            try:

                if path is None or os.path.isfile(path): 
                    continue

                # ops.update_listeners('evaluating', SCANNER, path)

                if os.path.isdir(path) and os.access(path, os.R_OK):

                    # should_cache = last_expanded_path is None
                    # if self.high_scan:
                    #     if last_expanded_path:
                    #         if not path.startswith(last_expanded_path):
                    #             last_expanded_path = None
                    #             should_cache = True

                    #     if should_cache:
                    #         ops.cache_ops(path, HSCAN, SCANNER)

                    # if self.deep_scan or self.path_has_handlers(path) or self.context.path_in_fifos(path, SCAN):

                    if self.path_expands(path):
                        # self.context.clear_active(SCAN)
                        last_expanded_path = path
                        continue

                    if self.should_skip(path): 
                        continue

                    
                    # try:
                    self.before(path)

                    # start_read_cache_size = len(cache2.get_keys(ops.OPS, READ))
                    LOG.debug("scanning %s..." % path)
                    # ops.update_listeners('scanning', SCANNER, path)
                    self.handle_context_path(path)
                    # end_read_cache_size = len(cache2.get_keys(ops.OPS, READ))

                    # self._post_scan(path, start_read_cache_size != end_read_cache_size)
                    
                    if self.after:
                        self.after(path)

                elif not os.access(path, os.R_OK):
                    #TODO: parrot behavior for IOError as seen in read.py 
                    ERR.warning("%s isn't currently available." % (path))
                    print("%s isn't currently available." % (path))

            except Exception, err:
                self.handle_error(err, path)
                LOG.error(': '.join([err.__class__.__name__, err.message]), exc_info=True)
