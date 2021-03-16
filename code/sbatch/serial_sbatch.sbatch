#!/bin/bash
#SBATCH -J r
#SBATCH -o hansard.out
#SBATCH -p standard-mem-s,standard-mem-m,standard-mem-l,medium-mem-1-s,medium-mem-1-m,medium-$
#SBATCH --mem=30G
#SBATCH --exclusive
#SBATCH --mail-user="steph.buon@gmail.com"
#SBATCH --mail-type=ALL

module purge
module load r

hostname
Rscript filter_for_keyword_triples.R
