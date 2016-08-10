#! /usr/bin/python

import os, json, pprint, sys, random, logging, traceback, thread
from elasticsearch import Elasticsearch
import data
import mySQL4es

pp = pprint.PrettyPrinter(indent=4)

def clean_str(string):
    return string.lower().replace(', ', ' ').replace('_', ' ').replace(':', ' ').replace(' ', '')

class MediaMatcher:
    def __init__(self, mediaManager):
        self.mfm = mediaManager
        self.es = mediaManager.es
        self.comparison_fields = []
        self.index_name = mediaManager.index_name
        self.document_type = mediaManager.document_type

        if self.name() is not None:
            rows = mySQL4es.retrieve_values('matcher_field', ['matcher_name', 'field_name'], [self.name()])
            for r in rows:
                self.comparison_fields.append(r[1])

    def match(self, media):
        raise Exception('Not Implemented!')

    # TODO: add index_name
    # TODO: add matcher to match record. assign weights to various matchers.
    def match_recorded(self, media_id, match_id):

        rows = mySQL4es.retrieve_values('matched', ['media_doc_id', 'match_doc_id', 'matcher_name', 'index_name'], [media_id, match_id, self.name(), self.index_name])
        if len(rows) == 1:
            return True

        # check for reverse match
        rows = mySQL4es.retrieve_values('matched', ['media_doc_id', 'match_doc_id', 'matcher_name', 'index_name'], [match_id, media_id, self.name(), self.index_name])
        if len(rows) == 1:
            return True

    def name(self):
        raise Exception("Not Implemented!")

    def print_match_details(self, orig, match):

        if orig['_source']['file_size'] >  match['_source']['file_size']:
            print(orig['_id'] + ': ' + orig['_source']['file_name'] +' >>> ' + match['_id'] + ': ' + match['_source']['absolute_file_path'] + ', ' + str(match['_source']['file_size']))

        elif orig['_source']['file_size'] ==  match['_source']['file_size']:
            print(orig['_id'] + orig['_source']['file_name'] + ' === ' + match['_id'] + ': ' + match['_source']['absolute_file_path'] + ', ' + str(match['_source']['file_size']))

        elif orig['_source']['file_size'] <  match['_source']['file_size']:
            print(orig['_id'] + orig['_source']['file_name'] + ' <<< ' + match['_id'] + ': ' + match['_source']['absolute_file_path'] + ', ' + str(match['_source']['file_size']))

    def record_match(self, media_id, match_id, matcher_name, index_name, matched_fields, match_score):
        # if self.mfm.debug == True: print 'recording match'
        if not self.match_recorded(media_id, match_id) and not self.match_recorded(match_id, media_id):
            mySQL4es.insert_values('matched', ['media_doc_id', 'match_doc_id', 'matcher_name', 'index_name', 'matched_fields', 'match_score'],
                [media_id, match_id, matcher_name, index_name, str(matched_fields), str(match_score)])

class FolderNameMatcher(MediaMatcher):
    def match(self, media):
        pass
        raise Exception('Not Implemented!')

class ElasticSearchMatcher(MediaMatcher):
    def get_query(self, media):
        raise Exception('Not Implemented!')

# TODO: add index_name
class BasicMatcher(ElasticSearchMatcher):

    def name(self):
        return 'basic'

    def get_query(self, media):
        # print media.file_name
        return { "query": { "match" : { "file_name": unicode(media.file_name) }}}

        # org = self.mfm.get_doc(media)
        # pp.pprint(org)
        # return {
        #   "query": {
        #     "bool": {
        #       "should":   { "term": { "TIT2": org['_source']['TIT2'] }},
        #       "should":   { "term": { "TPE1": org['_source']['TPE1'] }},
        #       "should":   { "term": { "TALB": org['_source']['TALB'] }}
        #     }
        #   }
        # }

    def match(self, media):

        if media.esid is None:
            if self.mfm.debug: print("--- No esid: " + media.file_name)
            return

        match = None
        try:

            if self.mfm.debug:
                print("seeking matches: " + media.esid + ' ::: ' + '.'.join([media.file_name, media.ext]))

            if not self.mfm.doc_exists(media, True):
                raise Exception("doc doesn't exist")

            orig = self.mfm.get_doc(media)

            res = self.es.search(index=self.index_name, doc_type=self.document_type, body=self.get_query(media))
            for match in res['hits']['hits']:
                if match['_score'] > 5:
                    if match['_id'] == orig['_id']:
                        continue

                    try:
                        # if self.mfm.debug: print("possible match: " + match['_id'] + " - " + match['_source']['absolute_file_path'])
                        match_fails = False
                        matched_fields = ['file_name']

                        for field in self.comparison_fields:
                                if field in match['_source'] and field in orig['_source']:
                                    matched_fields +' field'
                                    if util.str_clean4comp( match['_source'][field]) != util.str_clean4comp(orig['_source'][field]):
                                        match_fails = True

                        if match_fails == False:
                            self.print_match_details(orig, match)
                            # mySQL4es.DEBUG = True

                            # self.mfm.ensure_exists_in_mysql(match['_id'], match['_source']['absolute_file_path'])
                            try:
                                thread.start_new_thread( mySQL4es.ensure_exists_in_mysql, ( match['_id'], match['_source']['absolute_file_path'], self.index_name, self.document_type, ) )
                            except Exception, err:
                                print err.message
                                traceback.print_exc(file=sys.stdout)
                            self.record_match(media.esid,  match['_id'], self.name(), self.index_name, matched_fields, match['_score'])
                            # try:
                            #     thread.start_new_thread( self.record_match, ( media.esid,  match['_id'], self.name(), self.index_name, matched_fields, match['_score'], ) )
                            # except Exception, err:
                            #     print err.message
                            # mySQL4es.DEBUG = False

                    except KeyError, err:
                        print err.message
                        traceback.print_exc(file=sys.stdout)


        except Exception, err:
            print err.message
            traceback.print_exc(file=sys.stdout)
