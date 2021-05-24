#!/bin/bash
#SBATCH -J r # maybe
#SBATCH -o temporal_events_count.out # or this
#SBATCH -p standard-mem-s,standard-mem-m,standard-mem-l,medium-mem-1-s,medium-mem-1-m,medium-mem-2,high-mem-1,high-mem-2 
#SBATCH --mem=50G
#SBATCH --exclusive
#SBATCH --mail-user="steph.buon@gmail.com"
#SBATCH --mail-type=ALL

module purge
module load r

hostname
Rscript main_tec_ocr_handling.R

