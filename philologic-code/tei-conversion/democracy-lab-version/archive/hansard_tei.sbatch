#!/bin/bash
#SBATCH --job-name=hansard_tei
#SBATCH -p standard-mem-s,standard-mem-m,standard-mem-l,medium-mem-1-s,medium-mem-1-m,medium-mem-2
#SBATCH --mem=200G
#SBATCH --time=240


# Create a temporary directory for the job in local storage #
TMPDIR=$SCRATCH/$SLURM_JOBID
export TMPDIR
mkdir -p $TMPDIR

# Create virtual python environment #
module purge
module load python/3
virtualenv --no-download $TMPDIR/env
source $TMPDIR/env/bin/activate
pip install --no-index --upgrade pip

# Install required packages. #
pip install pandas trafilatura==0.7.0

# Run script #
python hansard_tei.py

# Cleanup #
deactivate
rm -rf $SCRATCH/$SLURM_JOBID
