import datetime
import logging
import os
import subprocess
import sys

from alchemy import SQLOperationRecord, SQLServiceExec
import config
import sql
from core import cache2, log

from start import show_logo, display_status

LOG = log.get_safe_log(__name__, logging.INFO)
ERR = log.get_safe_log('errors', logging.WARNING)

OPS = 'ops'
EXEC = 'exec'

OP_RECORD = {'pid': str(config.pid), 'operation_name': None, 'start_time': config.start_time, 'end_time': None, \
    'asset_id': None, 'target_path': None, 'status': None, 'persisted': False}

EXEC_RECORD = {'id': None, 'pid': str(config.pid), 'start_time': config.start_time, 'end_time': None, \
    'effective_dt': datetime.datetime.now(), 'expiration_dt': None, 'halt_requested':False, \
    'stop_requested':False, 'reconfig_requested': False, 'status': 'starting', 'commands': [], 'persisted': False}

#TODO: move this decorator to introspection and apply to all functions as exception_trap
def ops_func(function):
    def wrapper(*args, **kwargs):
        try:
            func_info = 'calling %s.%s' % (function.func_code.co_filename, function.func_code.co_name)
            LOG.debug(func_info)
            check_status()
            return function(*args, **kwargs)
        except RuntimeWarning, warn:
            ERR.warning(': '.join([warn.__class__.__name__, warn.message]))
        except Exception, err:
            ERR.error(': '.join([err.__class__.__name__, err.message]))
            raise err
    return wrapper

def create_op_key(path, operation, operator):
    return cache2.create_key(OPS, config.pid, operation, operator, path)


def get_op_key(path, operation, operator):
    return cache2.get_key(OPS, config.pid, operation, operator, path)


@ops_func
def cache_ops(path, operation, operator=None, apply_lifespan=False, op_status=None):
    if operator is None:
        LOG.debug('%s retrieving %s operations (%s)...' % (OPS, operation, op_status))
    else:
        LOG.debug('%s retrieving %s operations (%s)...' % (operator, operation, op_status))

    update_listeners('retrieving %s ops (%s)...' % (operation, op_status), operator, path)

    if op_status is None:
        rows = SQLOperationRecord.retrieve(path, operation, operator, apply_lifespan=apply_lifespan) 
    else:
        rows = SQLOperationRecord.retrieve(path, operation, operator, apply_lifespan=apply_lifespan, op_status=op_status)

    count = len(rows)
    cached_count = 0

    LOG.debug('%s caching %i %s operations (%s)...' % (operator, count, operation, op_status))
    for op_record in rows:
        update_listeners('caching %i %s operations  (%s)...' % (count - cached_count, operation, op_status), operator, path)
        cache_op(op_record)
        cached_count += 1

@ops_func 
def discard_ops(path, operation=None, operator=None):
    LOG.debug('discarding op records...')

    operator = '*' if operator is None else operator
    operation = '*' if operation is None else operation

    keys = cache2.get_keys(OPS, "*", operation, operator, path)

    for key in keys:
        record = cache2.get_hash2(key)
        cache2.delete_key(key)

@ops_func 
def cache_op(op_record):
    key = cache2.create_key(OPS, config.pid, op_record.operation_name, op_record.operator_name, op_record.target_path)
    cache2.set_hash2(key, {'persisted': True, 'operation_name':  op_record.operation_name, 'operator_name':  op_record.operator_name, \
        'target_path': op_record.target_path})


def clear_cached_operation(path, operation, operator=None):
    op_key = get_op_key(path, operation, operator)
    cache2.delete_hash2(op_key)
    cache2.delete_key(op_key)


def flush_cache(resuming=False):
    write_ops_data(os.path.sep, resuming=resuming)
    if resuming is False:
        LOG.info('flushing redis datastore, keys remain')
        cache2.datastore.flushdb()
        cache2.hashstore.flushdb()
        cache2.liststore.flushdb()
        cache2.orderedliststore.flushdb()


def mark_operation_invalid(path, operation, operator):
    LOG.debug("marking operation invalid: %s:::%s - path %s " % (operator, operation, path))

    op_key = get_op_key(path, operation, operator)
    values = cache2.get_hash2(op_key)
    values['status'] = 'INVALID'
    cache2.set_hash2(op_key, values)


def operation_completed(path, operation, operator=None):
    LOG.debug("checking for record of %s:::%s on path %s " % (operator, operation, path))
    if operator is None:
        rows = sql.retrieve_values('op_record', ['operation_name', 'target_path', 'status', 'start_time', 'end_time'],
                                   [operation, path, 'COMPLETE'])
    else:
        rows = sql.retrieve_values('op_record', ['operator_name', 'operation_name', 'target_path', 'status', 'start_time', 'end_time'],
                                   [operator, operation, path, 'COMPLETE'])

    result = len(rows) > 0
    LOG.debug('operation_completed(path=%s, operation=%s) returns %s' % (path, operation, str(result)))
    return result


def operation_in_cache(path, operation, operator=None):
    op_key = get_op_key(path, operation, operator)
    values = cache2.get_hash2(op_key)
    return 'persisted' in values and values['persisted'] == 'True'
    #LOG.debug('operation_in_cache(path=%s, operation=%s) returns %s' % (path, operation, str(result)))


def pop_operation():
    stack_key = cache2.get_key(OPS, config.pid, 'op-stack')
    cache2.lpop2(stack_key)
    
    last_op_key = cache2.lpeek2(stack_key)

    if last_op_key is None or last_op_key == 'None':
        set_service_execord_value('current_operation', None)
        set_service_execord_value('current_operator', None)
        set_service_execord_value('operation_status', None)
        update_listeners('', '', '')
    else:
        op_rec = cache2.get_hash2(last_op_key)
        service_exec = cache2.get_hash2(get_exec_key())
        
        service_exec['current_operation'] = op_rec['operation_name']
        service_exec['current_operator'] = op_rec['operator_name']
        service_exec['operation_status'] = op_rec['status']
        cache2.set_hash2(get_exec_key(), service_exec)

        update_listeners(op_rec['operation_name'], op_rec['operator_name'], op_rec['target_path'])


def push_operation(path, operation, operator):
    op_key = get_op_key(path, operation, operator)
    stack_key = cache2.get_key(OPS, config.pid, 'op-stack')
    cache2.lpush(stack_key, op_key)

    update_listeners(operation, operator, path)


def record_op_begin(path, operation, operator, esid=None):
    LOG.debug("recording operation beginning: %s:::%s on %s" % (operator, operation, path))
    
    op_record = OP_RECORD
    op_record['operation_name'] = operation
    op_record['operator_name'] = operator
    op_record['start_time'] = datetime.datetime.now().isoformat()
    if esid:
        op_record['asset_id'] = esid
    op_record['target_path'] = path
    op_record['status'] = 'ACTIVE'
    op_key = create_op_key(path, operation, operator)
    cache2.set_hash2(op_key, op_record)

    service_exec = cache2.get_hash2(get_exec_key())
    service_exec['current_operation'] = operation
    service_exec['current_operator'] = operator
    service_exec['operation_status'] = 'ACTIVE'
    cache2.set_hash2(get_exec_key(), service_exec)

    push_operation(path, operation, operator)
    update_listeners(operation, operator, path)

def record_op_complete(path, operation, operator, esid=None, op_failed=False):
    LOG.debug("recording operation complete: %s:::%s on %s - path %s " % (operator, operation, esid, path))

    op_key = get_op_key(path, operation, operator)
    record = cache2.get_hash2(op_key)

    if len(record) > 0:
        record['status'] = "FAIL" if op_failed else 'COMPLETE'
        record['end_time'] = datetime.datetime.now().isoformat()
        cache2.set_hash2(op_key, record)

        pop_operation()


def retrieve_ops__data(path, operation, operator=None, apply_lifespan=False):
    if apply_lifespan:
        start_time = datetime.date.today() + datetime.timedelta(0 - config.op_life)
        if operator is None:
            return sql.run_query_template('ops_retrieve_complete_ops_apply_lifespan', operation, start_time, path, \
                schema=config.db_service)
        else:
            return sql.run_query_template('ops_retrieve_complete_ops_apply_lifespan', operator, operation, start_time, path, \
                schema=config.db_service)
    else:
        if operator is None:
            return sql.run_query_template('ops_retrieve_complete_ops', operation, path, \
                schema=config.db_service)
        else:
            return sql.run_query_template('ops_retrieve_complete_ops_operator', operator, operation, path, \
                schema=config.db_service)


def update_ops_data(path, key, value, operation=None, operator=None):
    LOG.debug('updating operation records')

    operator = '*' if operator is None else operator
    operation = '*' if operation is None else operation

    op_keys = cache2.get_keys(OPS, config.pid, operation, operator, path)
    for op_key in op_keys:
        record = cache2.get_hash2(op_key)
        if len(record) > 0:
            record[key] = value
            cache2.set_hash2(op_key, record)


def write_ops_data(path, operation=None, operator=None, resuming=False):
    LOG.debug('writing op records...')

    operator = '*' if operator is None else operator
    operation = '*' if operation is None else operation

    # if resuming and config.old_pid:
    #     keys = cache2.get_keys(OPS, config.old_pid, operation, operator, path)
    # else:
    #     keys = cache2.get_keys(OPS, config.pid, operation, operator, path)

    keys = cache2.get_keys(OPS, "*", operation, operator, path)

    for key in keys:
        record = cache2.get_hash2(key)
        skip = False
        for field in OP_RECORD:
            if not field in record:
                skip = True
                break

        if skip or record['persisted'] == 'True' or record['status'] == 'INVALID': 
            continue

        if record['end_time'] == 'None':
            record['status'] = 'INCOMPLETE' if resuming is False else 'INTERRUPTED'

        if record['status'] == 'INTERRUPTED':
            pass

        if record['status'] == 'INCOMPLETE':
            record['end_time'] = datetime.datetime.now().isoformat()

        # TODO: if esids were cached after asset has been indexed, they COULD be inserted HERE instead of using update_ops_data() post-ipso
        update_listeners('writing %s' % record['operation_name'], record['operator_name'], record['target_path'])

        SQLOperationRecord.insert(operation_name=record['operation_name'], operator_name=record['operator_name'], asset_id=record['asset_id'], \
            target_path=record['target_path'], start_time=record['start_time'], end_time=record['end_time'], status=record['status'])

        cache2.delete_key(key)

    LOG.info('%s operations have been updated for %s in MySQL' % (operation, path))


# execution record

def get_exec_key(no_pid=False):
    return cache2.get_key(NO_PID, OPS, EXEC) if no_pid else cache2.get_key(str(config.pid), OPS, EXEC)
    

def get_service_execord_value(field):
    values = cache2.get_hash2(get_exec_key())
    if field in values:
        return  values[field]


def insert_service_execord():
    values = cache2.get_hash2(get_exec_key())
    try:
        return SQLServiceExec.insert(values)
    except Exception, err:
        ERR.error(err.message) 


def insert_exec_complete_record():
    values = cache2.get_hash2(get_exec_key())
    values['end_time'] = datetime.datetime.now()
    try:
        return SQLServiceExec.update(values)
    except Exception, err:
        ERR.error(err.message) 


# TODO: use execution record to select redis db
def record_exec():
    values = EXEC_RECORD 

    values['status'] = 'initializing'
    # values['pid'] = str(os.getpid())
    exec_key = get_exec_key()

    cache2.set_hash2(exec_key, values)
    service_exec = insert_service_execord()
    values['id'] = service_exec.id
    cache2.set_hash2(exec_key, values)

    update_listeners(OPS, exec_key, 'starting')


def get_service_execord(no_pid=False):
    return cache2.get_hash2(get_exec_key(no_pid=no_pid))


def set_service_execord_value(field, value):
    values = cache2.get_hash2(get_exec_key())
    values[field] = value
    cache2.set_hash2(get_exec_key(), values)

NO_PID = 'NOPID'

# external commands

def append_command(command, **kwargs):
    commands = get_service_execord_value('commands')
    commands.append(command, **kwargs)
    set_service_execord_value(command, **kwargs)


def check_status(opcount=None):

    values = cache2.get_hash2(get_exec_key())
    if 'pid' not in values:
        ERR.error('NO PID!!!')
        sys.exit(1)
        
    if opcount is not None and opcount % config.status_check_freq != 0: 
        return

    # update_listeners(OPS, get_exec_key(), 'checking status')

    # if reconfig_requested():
    #     update_listeners(OPS, get_exec_key(), 'reconfiguring')
    #     start.execute()
    #     clear_reconfig_request()

    if stop_requested():
        print('STOP requested. Stopping...')
        LOG.debug('STOP requested, terminating...')
        update_listeners(OPS, get_exec_key(), 'terminating')
        flush_cache()
        # cache.flush_cache()
        show_logo()
        display_status()
        insert_exec_complete_record()
        LOG.debug('system stopped')
        sys.exit(0)

    if halt_requested():
        print( 'HALT requested. Halting...')
        LOG.debug('HALT requested, terminating...')
        update_listeners(OPS, get_exec_key(), 'terminating')
        # flush_cache()
        # cache.flush_cache()
        show_logo()
        display_status()
        insert_exec_complete_record()
        LOG.debug('system halted')
        sys.exit(0)

@ops_func
def evaluate(no_pid=False):
    service_exec = get_service_execord(no_pid=no_pid)

    if start_requested():
        cache2.set_hash2(get_exec_key(no_pid=True), {'pid': NO_PID, 'start_requested': False, 'stop_requested':False, 'reconfig_requested': False})
        subprocess.call(["$MILDRED_HOME/bin/run.sh"], shell=True)

    commands = get_service_execord_value('commands')
    if commands is not None and len(commands) > 0:
        eval_commands()


def eval_commands():
    commands = get_service_execord_value('commands')
    if commands is not None:
        if 'listen' in commands:
            pass

        if 'execute' in commands:
            pass


def clear_reconfig_request():
    set_service_execord_value('reconfig_requested', False)


def reconfig_requested():
    values = cache2.get_hash2(get_exec_key())
    if len(values) > 0:
        try:
            return values['pid'] == config.pid and values['reconfig_requested'] == 'True'
        except KeyError, kerr:
            ERR.error(': '.join([kerr.__class__.__name__, kerr.message]))


def stop_requested():
    values = cache2.get_hash2(get_exec_key())
    try:
        if len(values) > 0:
            return values['pid'] == config.pid and values['stop_requested'] == 'True'
    except KeyError, kerr:
        ERR.error(': '.join([kerr.__class__.__name__, kerr.message]))

def halt_requested():
    values = cache2.get_hash2(get_exec_key())
    try:
        if len(values) > 0:
            return values['pid'] == config.pid and values['halt_requested'] == 'True'
    except KeyError, kerr:
        ERR.error(': '.join([kerr.__class__.__name__, kerr.message]))

def start_requested():
    try:
        values = cache2.get_hash2(get_exec_key(no_pid=True))
        if len(values) > 0:
            return values['pid'] == NO_PID and values['start_requested'] == 'True'
    except KeyError, kerr:
        ERR.error(': '.join([kerr.__class__.__name__, kerr.message]))


# redis pub/sub

def update_listeners(operation, operator, target):
    
    operation = '' if operation is None else operation
    operator = '' if operator is None else operator
    target = '' if target is None else target

    # name = 'OPS'
    # channel = 'OPS'
    # message = '%s*%s*%s' % (operation, operator, target)
    cache2.datastore.publish('operation', operation)
    cache2.datastore.publish('operator', operator)
    cache2.datastore.publish('target', target)
