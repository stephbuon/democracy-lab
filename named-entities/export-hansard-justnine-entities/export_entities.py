import argparse
import multiprocessing
from queue import Empty
from os import cpu_count
import os
import pandas as pd

# By default: we require 2 processing cores.
CPU_CORES = 2

# Useful enumerations.
DATES = 0
EVENTS = 1


# Use SCRATCH if available, else use data folder in current directory.
INPUT_DIR = os.environ.get('SCRATCH', 'data')
OUTPUT_DIR = os.environ.get('SCRATCH', 'data')

INFILE = os.path.join(INPUT_DIR, 'hansard_justnine_12192019.csv')

# Number of rows per chunk to put into the queue.
CHUNK_SIZE = 2**16


def parse_config():
    global CPU_CORES
    parser = argparse.ArgumentParser()
    parser.add_argument('--cores', nargs=1, default=1, type=int, help='Number of cores to use.')
    args = parser.parse_args()
    CPU_CORES = args.cores[0]
    if CPU_CORES < 0 or CPU_CORES > cpu_count():
        raise ValueError('Invalid core number specified.')


# Worker function that will run in (n - 1) cores, processing chunks from the input queue.
def worker_function(input_queue: multiprocessing.Queue,
                    output_queue: multiprocessing.Queue):
    while True:
        dates = ([], [])  # Sentence ID's, entity names
        events = ([], [])  # Sentence ID's, entity names

        try:
            chunk: pd.DataFrame = input_queue.get(block=True)
        except Empty:
            continue
        else:
            if chunk is None:
                # Forward to export thread, which will terminate all workers.
                output_queue.put(None)
                continue

            chunk.dropna(inplace=True)
            chunk = chunk[chunk['entity_labels'].str.contains('DATE') | chunk['entity_labels'].str.contains('EVENT')]

            for sid, entities, labels in chunk.itertuples():
                for entity, label in zip(entities.split(','), labels.split(',')):
                    if label == 'DATE':
                        dates[0].append(sid)
                        dates[1].append(entity)
                    elif label == 'EVENT':
                        events[0].append(sid)
                        events[1].append(entity)

            output_queue.put((DATES, pd.DataFrame(events[1], columns=['entity'], index=events[0])))
            output_queue.put((EVENTS, pd.DataFrame(events[1], columns=['entity'], index=events[0])))


# This export function will run on a single process awaiting the worker processes to complete.
def export(output_queue):
    dates_df_list = []
    event_df_list = []

    while True:
        entry = output_queue.get(block=True)
        if entry is None:
            # Break out of the loop and export to file as we have reached the end of the queue.
            print('Finished all chunks.')
            break
        else:
            category, df = entry

            if category == DATES:
                dates_df_list.append(df)
            elif category == EVENTS:
                event_df_list.append(df)

    print('Concatenating...')
    dates_df = pd.concat(dates_df_list)
    dates_df.index.name = 'sentence_id'
    events_df = pd.concat(event_df_list)
    events_df.index.name = 'sentence_id'

    print('Writing to file...')
    dates_df.to_csv(os.path.join(OUTPUT_DIR, 'hansard_ner_time.csv'))
    events_df.to_csv(os.path.join(OUTPUT_DIR, 'hansard_ner_event.csv'))


if __name__ == '__main__':
    parse_config()

    from multiprocessing import Queue, Process
    inq = Queue()
    outq = Queue()

    # Reserve a core for the export process.
    process_args = (inq, outq)
    processes = [Process(target=worker_function, args=process_args) for _ in range(CPU_CORES - 1)]

    for p in processes:
        p.start()

    export_process = Process(target=export, args=(outq,))
    export_process.start()

    print('Queueing chunks...')
    for chunk_df in pd.read_csv(INFILE, sep=',', chunksize=CHUNK_SIZE,
                                usecols=['sentence_id', 'sentence_entities', 'entity_labels'],
                                index_col='sentence_id'):
        inq.put(chunk_df)

    # A None in the input queue signals that no more entries will be followed.
    # Allows a worker process to notify to the export process to begin the export.
    inq.put(None)

    print('Waiting on export...')
    export_process.join()  # Wait on the export process.

    # Terminate all the worker processes.
    for process in processes:
        process.terminate()

    print('Exiting...')
