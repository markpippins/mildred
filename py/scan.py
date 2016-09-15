#! /usr/bin/python

'''
   Usage: scan.py [(--path <path>...) | (--pattern <pattern>...) ]

   --path, -p                   The path to scan

'''

import os, json, pprint, sys, traceback

import cache, config, start, ops, calc, sql, util, esutil, library

from asset import AssetException, Asset, MediaFile, MediaFile
from library import Library
from direct import Directive
from read import Reader
from walk import MediaLibraryWalker

pp = pprint.PrettyPrinter(indent=4)

class Scanner(MediaLibraryWalker):
    def __init__(self):
        super(Scanner, self).__init__()

        self.directive = None
        self.document_type = config.MEDIA_FILE
        
        self.do_cache_locations = True
        self.do_deep_scan = config.deep
        
        self.location_cache = {}

        self.library = Library()
        self.reader = Reader()
        
    # MediaLibraryWalker methods begin

    def after_handle_root(self, root):
        if config.scan:
            folder = self.library.folder
            if folder is not None and folder.absolute_path == root:
                if folder is not None and not ops.operation_completed(folder, 'ID3v2', 'scan'):
                    ops.record_op_complete(folder, 'ID3v2', 'scan')

    def before_handle_root(self, root):
        if config.scan:
            ops.do_status_check()

            # if config.server_debug: print 'examining: %s' % (root)
            
            self.library.folder = None
            
            if ops.operation_in_cache(root, 'scan', 'ID3v2'):
            # and not self.do_deep_scan: # and not root in config.locations_ext:
                if config.server_debug: print 'scan operation record found for: %s' % (root)
                return

            try:
                if library.path_contains_media(root, self.directive.extensions):
                    self.library.set_active( root)

            except AssetException, err:
                self.library.folder = None
                print ': '.join([err.__class__.__name__, err.message])
                if config.server_debug: traceback.print_exc(file=sys.stdout)
                library.handle_asset_exception(err, root)

            except Exception, err:
                print ': '.join([err.__class__.__name__, err.message])
                if config.server_debug: traceback.print_exc(file=sys.stdout)

    def handle_root(self, root):
        if config.scan:
            folder = self.library.folder
            if folder is not None and ops.operation_completed(folder, 'ID3v2', 'scan'):
                print '%s has been scanned.' % (root)
            elif folder is not None:
                if config.server_debug: print 'scanning folder: %s' % (root)
                ops.record_op_begin(folder, 'ID3v2', 'scan')
                for filename in os.listdir(root):
                    self.process_file(os.path.join(root, filename), library, self.reader)
        # else: self.library.set_active(root)

    def handle_root_error(self, err):
        print ': '.join([err.__class__.__name__, err.message])

    # MediaLibraryWalker methods end

    def process_file(self, filename, library, reader):
        for extension in self.directive.extensions:
            if reader.approves(filename):
                media = self.get_media_object(filename)
                # TODO: remove es and MySQL records for nonexistent files
                if media is None or media.ignore(): continue
                # scan tag info if this file hasn't been assigned an esid
                if media.esid is None: 
                    reader.read(media, library)

    def scan(self, directive):
        self.directive = directive
        for location in directive.locations:
            if os.path.isdir(location) and os.access(location, os.R_OK):
                cache.cache_docs(config.MEDIA_FOLDER, location)
                ops.cache_ops(False, location, 'scan', 'ID3v2')
                self.walk(location)
                ops.write_ops_for_path(location, 'ID3v2', 'scan')
                cache.clear_docs(config.MEDIA_FOLDER, location)
            elif config.server_debug:  print "%s isn't currently available." % (location)

        # cache.cache_docs(config.MEDIA_FILE, path)
        print '\n-----scan complete-----\n'

    # TODO: move this to asset
    def get_media_object(self, absolute_path):

        if config.server_debug: print "creating instance for %s." % (absolute_path)
        if not os.path.isfile(absolute_path) and os.access(absolute_path, os.R_OK):
            if config.server_debug: print "Either file is missing or is not readable"
            return null

        media = MediaFile()
        path, filename = os.path.split(absolute_path)
        extension = os.path.splitext(absolute_path)[1]
        filename = filename.replace(extension, '')
        extension = extension.replace('.', '')
        location = self.get_location(absolute_path)

        foldername = parent = os.path.abspath(os.path.join(absolute_path, os.pardir))

        media.absolute_path = absolute_path
        media.file_name = filename
        media.location = location
        media.ext = extension
        media.folder_name = foldername
        media.file_size = os.path.getsize(absolute_path)

        media.esid = cache.get_cached_esid(config.MEDIA_FILE, absolute_path)

        return media

    def get_location(self, path):
        parent = os.path.abspath(os.path.join(path, os.pardir))
        if parent in self.location_cache:
            # if config.server_debug: print "location for path %s found." % (path)
            return self.location_cache[parent]

        self.location_cache = {}

        if config.server_debug: print "determining location for %s." % (parent.split('/')[-1])
    
        for location in config.locations:
            if location in path:
                self.location_cache[parent] = os.path.join(config.START_FOLDER, folder)
                return self.location_cache[parent]

        for location in config.locations_ext:
            if location in path:
                self.location_cache[parent] = os.path.join(folder)
                return self.location_cache[parent]

        return None

def scan(directive):
    scanner = Scanner()
    scanner.scan(directive)