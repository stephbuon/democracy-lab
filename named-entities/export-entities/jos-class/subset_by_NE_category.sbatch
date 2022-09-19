#!/bin/bash
#SBATCH -J subset_by_NE_category
#SBATCH -o subset_by_NE_category.out
#SBATCH -p standard-mem-s,standard-mem-m,standard-mem-l,medium-mem-1-s,medium-mem-1-m,medium-mem-1-l,high-mem-1,high-mem-2
#SBATCH --mem=100G
#SBATCH --exclusive

module purge
module load r

hostname
Rscript subset_by_NE_category.R
