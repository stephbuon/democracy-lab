#!/bin/bash
#SBATCH -J topic_model
#SBATCH -o topic_model.out
#SBATCH -p standard-mem-m,standard-mem-l,medium-mem-2,medium-mem-1-m,medium-m-1-l
#SBATCH --mem=250G
#SBATCH --exclusive
#SBATCH --cpus-per-task=32

module purge
module load python/3

export TMPDIR=${JOB_SCRATCH}

python topic_model.py --cores ${SLURM_CPUS_PER_TASK}
