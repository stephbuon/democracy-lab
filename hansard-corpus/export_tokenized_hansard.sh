#!/bin/bash
#SBATCH -J export_tokenized_hansard
#SBATCH -o export_tokenized_hansard.out
#SBATCH -p standard-mem-s,standard-mem-m,standard-mem-l,medium-mem-1-s,medium-mem-1-m
#SBATCH --mem=200G
#SBATCH --exclusive
#SBATCH --ntasks-per-node=35

module purge
module load r

hostname
Rscript export_tokenized_hansard.R --cores ${SLURM_NTASKS}
