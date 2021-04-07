#!/bin/bash
#SBATCH -J r
#SBATCH -o quanteda_networks.out
#SBATCH -p standard-mem-s,standard-mem-m,standard-mem-l,medium-mem-1-s,medium-mem-1-m,medium-$
#SBATCH --mem=150G
#SBATCH --exclusive

module purge
module load r

hostname
Rscript quanteda_networks.R
