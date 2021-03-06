#! /usr/bin/python

'''
   Usage: disc.py [(--path <path>...)]

   --path, -p       The path to scan

'''

import logging
import os, sys

from docopt import docopt

import config
import const
import assets
import ops
import shallow
import search
# from const import Discover, SCAN, HSCAN, READ, USCAN, DEEP
from core import cache2
from core import log
from core.vector import Vector
from errors import ElasticDataIntegrityException
from read import Reader
from walk import Walker
import sql
import shallow

from ops import ops_func
import assets
from assets import Directory

LOG = log.get_safe_log(__name__, logging.INFO)
ERR = log.get_safe_log('errors', logging.WARNING)

# PERSIST = 'scan.persist'
# ACTIVE = 'active.scan.path'


class Discover(Walker):
    def __init__(self):
        super(Discover, self).__init__()
        self.folders = []
        self.file_types = shallow.get_file_types()
        self.categories = shallow.get_categories()
        self.types = shallow.get_directory_types()

    #@ops_func
    def handle_root(self, root):
        LOG.info("Considering %s" % root)
        if os.path.isdir(root) and os.access(root, os.R_OK):
            
            name = root.split(os.path.sep)[-1]

            if name in self.categories:
                shallow.set_directory_type(root, 'category')

            elif name in self.file_types:
                shallow.set_directory_type(root, 'format')

            elif shallow.path_is_media_root(root, self.categories):
                shallow.set_directory_type(root, 'collection')
            
            # elif shallow.path_is_media_root(root, self.categories):
            #     shallow.set_directory_type(root, 'location')
            
            elif not self.path_contains_files(root):
                return

            if root not in self.folders:
                self.folders.append(root)
               

    def path_contains_files(self, path):
        if os.path.isdir(path) and os.access(path, os.R_OK):
            for f in os.listdir(path):
                if os.path.isfile(os.path.join(path, f)):
                    return True

    def handle_root_error(self, err, root):
        pass
        # assets.set_active_directory(None)
        # TODO: connectivity tests, delete operations on root from cache.

    #@ops_func
    def assess(self):
        # apply a set of rules to eliminating redundant media folders.
        pass

    #@ops_func
    def process(self, folder):
        pass
        

def discover(startpath):
    if startpath not in shallow.get_directories():
        shallow.set_directory_type(startpath, 'path')
    d = Discover()
    d.walk(startpath)
    LOG.info('folders in selection:')
    for folder in d.folders:
        LOG.info(folder)
    return d.folders