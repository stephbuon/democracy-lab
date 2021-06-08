#!/bin/bash
#SBATCH -J jo-python       # name of the job — called r 
#SBATCH -o jo-python.out    # output file name 
#SBATCH -p medium-mem-1-l,high-mem-1,high-mem-2,medium-mem-2,medium-mem-1-l,medium-mem-1-s # name of the queue we're using
#SBATCH --mem=750G
#SBATCH --exclusive
#SBATCH --mail-user="joguldi@gmail.com"
#SBATCH --mail-type=ALL
#SBATCH --ntasks-per-node=36
#SBATCH --cores=1

module purge
module load python/3

python3 parallize-w-loop.py --cores ${SLURM_NTASKS}
