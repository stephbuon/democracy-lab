#!/bin/bash
#SBATCH --job-name=hansard_tei
#SBATCH -p standard-mem-s,standard-mem-m,standard-mem-l,medium-mem-1-s,medium-mem-1-m,medium-mem-2
#SBATCH --mem=64G
#SBATCH --time=360
#SBATCH -o hansard_tei.out

# Create virtual python environment #
module purge
module load python/3

# Run script #
echo "Running script..."
python tei_converter.py $SCRATCH/hansard_c19_04152021.tsv

