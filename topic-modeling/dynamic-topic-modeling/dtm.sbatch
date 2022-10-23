#!/bin/bash
#SBATCH --job-name=hansard_dtm
#SBATCH -p standard-mem-s,standard-mem-m,standard-mem-l,medium-mem-1-s,medium-mem-1-m
#SBATCH --mem=32G
#SBATCH --exclusive
#SBATCH --mail-user=acerpa@smu.edu
#SBATCH --mail-type=ALL
#SBATCH --ntasks-per-node=32
#SBATCH --time=480

cd $SCRATCH
cd $SCRATCH/dtm/dtm
./main --ntopics=500 --mode=fit --rng_seed=0  --initialize_lda=true --corpus_prefix=$SCRATCH/hansard  --outname=$SCRATCH/hansard_model  --top_chain_var=0.005   --alpha=0.01   --lda_sequence_min_iter=6   --lda_sequence_max_iter=20   --lda_max_em_iter=10
