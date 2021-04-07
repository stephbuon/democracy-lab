import os
import pandas as pd
import sys


TEI_HEADER = """<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE TEI.2 PUBLIC "-//TEI P4//DTD Lite DTD Driver File//EN" "http://www.tei-c.org/Lite/DTD/teixlite.dtd">

<TEI.2>
  <teiHeader>
    <fileDesc>
      <titleStmt>
        <title>Hansard Sample {YEAR}</title>
      </titleStmt>
      <publicationStmt>
        <publisher></publisher>
        <date>{YEAR}</date>
        <idno>{IDENTIFIER}</idno>
      </publicationStmt>
      <seriesStmt>
      </seriesStmt>
      <notesStmt>
      </notesStmt>
         <sourceDesc>
            <bibl>
               <author></author>
               <title>Hansard Sample {YEAR}</title>
               <editor></editor>
               <extent></extent>
               <imprint>
                  <pubPlace></pubPlace>
                  <publisher></publisher>
                  <date>{YEAR}</date>
               </imprint>
            </bibl>
         </sourceDesc>
    </fileDesc>
    <profileDesc>
      <creation>
          <date>{YEAR}</date>
      </creation>
      <textClass>
        <keywords>
        </keywords>
      </textClass>
    </profileDesc>
  </teiHeader>
<text>
"""


def export_tei(df):
    for file_id in df['src_file_id'].unique():
        file_df = df[df['src_file_id'] == file_id]
        handle_file(file_df, file_id)


def handle_file(df, file_id):
    year, month, day = df.iloc[0]['speechdate'].split('-')

    outfile = open(f'{output_folder}/{year}-{month}-{day}.{file_id}.xml', 'w+', encoding='utf-8')
    outfile.write(TEI_HEADER.format(YEAR=year, IDENTIFIER=file_id))

    for debate_id in df['debate_id'].unique():
        debate_df = df[df['debate_id'] == debate_id]
        debate_df = debate_df.sort_values('sentence_id')
        handle_debate(debate_df, outfile)

    outfile.write('</text>\n')
    outfile.write('</TEI.2>\n')

    outfile.close()


def handle_debate(df, outfile):
    date = df.iloc[0]['speechdate']
    debate = df.iloc[0]['debate']
    debate_id = df.iloc[0]['file_section_id']
    outfile.write(f'<div id="{debate_id}" date="{date}">\n')
    outfile.write(f'\t<head>{debate}</head>\n')

    for speech_id in df['speech_id'].unique():
        speech_df = df[df['speech_id'] == speech_id]
        speech_df = speech_df.sort_values('speech_id')
        handle_speech(speech_df, speech_id, outfile)
        outfile.write('\t</sp>\n')

    outfile.write('</div>\n')


def handle_speech(df, speech_id, outfile):
    speaker = df.iloc[0]['speaker']
    outfile.write(f'\t<sp who="{speaker}" id="{speech_id}">\n')
    outfile.write(f'\t\t<speaker>{speaker}</speaker>\n')

    for row in df.itertuples():
        print(row)
        sentence_id = row.section_sentence_id
        text = row.text
        outfile.write(f'\t\t<s id="{sentence_id}">{text}</s>\n')


if __name__ == '__main__':
    try:
        input_file = sys.argv[1]
    except IndexError:
        exit('Missing input file argument')

    if os.environ.get('SCRATCH'):
        base_folder = os.environ['SCRATCH']
    else:
        base_folder = ''

    output_folder = base_folder + '/tei_output'

    if not os.path.exists(output_folder):
        os.mkdir(output_folder)

    hansard_df = pd.read_csv(input_file, delimiter='\t')

    export_tei(hansard_df)
