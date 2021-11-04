#!/bin/bash
#SBATCH --job-name=hansard_speakers
#SBATCH -p standard-mem-s,standard-mem-m,standard-mem-l,medium-mem-1-s,medium-mem-1-m,medium-mem-2
#SBATCH --mem=32G
#SBATCH --exclusive
#SBATCH --ntasks-per-node=8
#SBATCH --time=15
module purge
module load python/3
cd $HOME
python3 export_entities.py --cores ${SLURM_NTASKS}
