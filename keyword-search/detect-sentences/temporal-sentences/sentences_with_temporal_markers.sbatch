#!/bin/bash
#SBATCH -J r
#SBATCH -o sentences_with_temporal_markers.out
#SBATCH -p standard-mem-s,standard-mem-m,standard-mem-l,medium-mem-1-s,medium-mem-1-m
#SBATCH --mem=50G
#SBATCH --exclusive

module purge
module load r/3.6.2

hostname
Rscript sentences_with_temporal_markers.R
