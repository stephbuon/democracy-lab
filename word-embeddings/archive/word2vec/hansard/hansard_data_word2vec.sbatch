#!/bin/bash
#SBATCH -J r
#SBATCH -o w2v_1grams.out
#SBATCH -p standard-mem-s,standard-mem-m,standard-mem-l,medium-mem-1-s,medium-mem-1-m,medium-mem-2
#SBATCH --mem=25G
#SBATCH --exclusive
#SBATCH --mail-user="steph.buon@gmail.com"
#SBATCH --mail-type=ALL

module purge
module load python/3

hostname
python3 hansard_data_word2vec.py
