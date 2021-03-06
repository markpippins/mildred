import config
import search
import sql

def copy_index(source_index, target_host, target_port, target_index):

    target = search.connect(target_host, target_port)

    rows = sql.retrieve_values('asset', ['index_name', 'id', 'asset_type'], [source_index])
    for row in rows:
        id = row[1]
        asset_type = row[2]
        doc = search.get_doc(asset_type, id)

        target.index(target_index, doc_type=asset_type, body=doc)


def main():
    config.es = search.connect(config.es_host, config.es_port)
    target_host = '54.175.142.35'
    target_port = 9200
    target_index = '?'

    copy_index('media', target_host, target_port, target_index)