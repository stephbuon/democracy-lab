#!/bin/bash
#SBATCH -J r # maybe
#SBATCH -o count_temporal_events.out # or this
#SBATCH -p standard-mem-s,standard-mem-m,standard-mem-l,medium-mem-1-s,medium-mem-1-m,medium-mem-2,high-mem-1,high-mem-2 
#SBATCH --mem=40G
#SBATCH --exclusive

module purge
module load r

hostname
Rscript count_temporal_events.R

