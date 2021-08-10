#!/bin/bash
#SBATCH -J r
#SBATCH -o preprocess_congress_data.out
#SBATCH -p standard-mem-s,standard-mem-m,standard-mem-l,medium-mem-1-s,medium-mem-2,medium-mem-1-m,high-mem-1,high-mem-2
#SBATCH --mem=80G
#SBATCH --exclusive
#SBATCH --mail-user="steph.buon@gmail.com"
#SBATCH --mail-type=ALL

module purge
module load r

hostname
Rscript preprocess_congress_data_3.R
