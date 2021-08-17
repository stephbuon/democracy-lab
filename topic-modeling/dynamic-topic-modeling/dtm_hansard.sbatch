#!/bin/bash
#SBATCH -J hansard_serial_dynamic_topic_model
#SBATCH -o hansard_serial_dynamic_topic_model.out
#SBATCH -p standard-mem-m,standard-mem-l,medium-mem-1-m,medium-mem-1-l,medium-mem-2,high-mem-1,high-mem-2
#SBATCH --mem=60G
#SBATCH --exclusive
#SBATCH --mail-user="steph.buon@gmail.com"
#SBATCH --mail-type=ALL

module purge
module load python/3

python3 dtm_hansard.py
