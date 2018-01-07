#! /usr/bin/python

import sys
import logging
from pydoc import locate

import config
import const
import library
import ops
from alchemy import SQLFileHandler, SQLFileType

from core import log

LOG = log.get_log(__name__, logging.DEBUG)
ERR = log.get_log('errors', logging.WARNING)


class Reader:
    def __init__(self):
        self.document_type = const.FILE
        self.extensions = ()
        self.file_handlers = ()
        # self.file_types = SQLFileType.retrieve_all()
        self.initialize_file_handlers()


    def initialize_file_handlers(self):
        handlers = SQLFileHandler.retrieve_active()
        for handler in handlers:
            qualified = []
            if handler.package: 
                qualified.append(handler.package)
                
            qualified.append(handler.module)            
            qualified.append(handler.class_name)            

            qname = '.'.join(qualified)
            clazz = locate(qname)
            if clazz is None:
                print "%s not found." % qname
                continue

            instance = clazz()

            for registration in handler.registrations:
                ext = registration.file_type.ext.lower()
                if ext not in instance.extensions:
                    instance.extensions += ext,
                if ext not in self.extensions:
                    self.extensions += ext,
            
            self.file_handlers += instance,


    def has_handler_for(self, filename):
        if filename.lower().startswith('incomplete~') or filename.lower().startswith('~incomplete'):
            return False

        for extension in self.extensions:
            if filename.lower().endswith(extension):
                return True


    def invalidate_read_ops(self, path):
        for file_handler in self.file_handlers:
           if ops.operation_in_cache(path, const.READ, file_handler.name):
               ops.mark_operation_invalid(path, const.READ, file_handler.name)


    def read(self, path, data, file_handler_name=None, force_read=False):
        for file_handler in self.file_handlers:
            if file_handler_name is None or file_handler.name == file_handler_name:
                for extension in file_handler.extensions:
                    if path.lower().endswith(extension) or '*' in file_handler.extensions or force_read:
                        if ops.operation_in_cache(path, const.READ, file_handler.name):
                            continue
                        else: 
                            return file_handler.handle_file(path, data)


