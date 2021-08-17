#!/bin/bash
#SBATCH -J preprocess_congress_data_2
#SBATCH -o preprocess_congress_data_2.out
#SBATCH -p standard-mem-s,standard-mem-m,standard-mem-l,medium-mem-1-s,medium-mem-1-m,medium-mem-1-l,high-mem-1,high-mem-2
#SBATCH --mem=50G
#SBATCH --exclusive
#SBATCH --ntasks-per-node=36
#SBATCH --mail-user="steph.buon@gmail.com"
#SBATCH --mail-type=ALL

module purge 
module load python

python3 preprocess_congress_data_2.py --cores ${SLURM_NTASKS}
