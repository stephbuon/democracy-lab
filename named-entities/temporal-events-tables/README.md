# Directory

| Code | Description |
| --- | --- |
| **temporal_events_tables.R** | Count triples that occur in sentences with temporal events. Export to tables. |
| **debut_entity_count.R** | Explore entity counts at different stages of the code. Checl that counts are consistent after joins. |
| **triples_list.txt** | List of triples to explicity extract (versus extracting all triples). |
| **events_list.txt** | List of events to explicity extract (versus extracting all events). |
| **regex_list.txt** | List of regexes to match. |

### Detailed Usage: 
**temporal_events_tables.R** has four conditional parameters: select_events, select_triples, ocr_handling, and fact_checking.
- select_events: 
- select_triples: If true, extract the triples on **triples_list.txt**. 
- ocr_handling:
- fact_checking: export a csv file with the event, said to belong to a sentence, and the original sentence for validation.

### Definitions: 
- Temporal event: a noteable historical event in time (i.e. French Revolution, Gordon Riots...)

###### Notes
Other useful table libraries to know about: DT, formattable, and stargazers. 

