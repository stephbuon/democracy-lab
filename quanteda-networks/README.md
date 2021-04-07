## About the quanteda-networks pipeline

__quanteda-networks__ (formerly, quanteda-code-for-app-2), generates (enter).  

__quanteda-networks.R__ is memory intensive, and will likely need to be run on M2. For this reason, __quanteda-networks.R__ is designed to be submitted as an sbatch job, although it can run on a local machine. To comply with sbatch requirments, functions have been added to the start of the script (enter). 

### Control Flow 

The __quanteda-networks__ control flow is separated into three major operations: 
- applying quantedafy
- generating graphs
- generating semantic networks  

The control flow gives programmers the option to run the pipeline in its entirety, generating entirely new data and visualizations, or run desired sections independently. Programmers must specify boolean values for __do_quantedafy_hansard__, __do_generate_graphs__, and __do_generate_semantic_networks__ at the start of the script. 

__TRUE__ will run the operations belonging to the section, and __FALSE__ will skip the operations and instead import an __.RData__ file with data from the last run.
