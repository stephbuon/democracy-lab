#!/bin/bash
#SBATCH -J topic_model
#SBATCH -o topic_model.out
#SBATCH -p standard-mem-m,standard-mem-l,medium-mem-2,medium-mem-1-m,medium-m-1-l
#SBATCH --mem=150G
#SBATCH --exclusive
#SBATCH --ntasks-per-node=35

module purge
module load python/3

python topic_model.py --cores ${SLURM_NTASKS}
