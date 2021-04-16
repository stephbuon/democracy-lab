#!/bin/bash
#SBATCH -J r
#SBATCH -o quanteda_networks.out
#SBATCH -p standard-mem-s,standard-mem-m,standard-mem-l,medium-mem-1-s,medium-mem-1-m
#SBATCH --mem=200G
#SBATCH --exclusive

module purge
module load r/3.6.2

hostname
Rscript quanteda_networks.R
