#!/bin/bash
#SBATCH -J topic_model
#SBATCH -o topic_model.out
#SBATCH -p standard-mem-m,standard-mem-l,medium-mem-2,medium-mem-1-m
#SBATCH --mem=250G
#SBATCH --exclusive
#SBATCH --cpus-per-task=34
#SBATCH --array=0-10

module purge
module load python/3

export TMPDIR=${JOB_SCRATCH}

decades=(1800 1810 1820 1830 1840 1850 1860 1870 1880 1890 1900)
path='/scratch/group/pract-txt-mine/sbuongiorno/hansard_decades/'

python topic_model.py 100 ${path} ${decades[${SLURM_ARRAY_TASK_ID}]} ${SLURM_CPUS_PER_TASK}
