
library(tidytext)
library(tidyverse)
library(viridis)
library(Hmisc)
library(foreach)
library(doParallel)
library(itertools)

hansard <- read_csv("hansard_justnine_11.08.2019.csv")

j = 1 # how many words constitute a phrase?


#setup parallel backend to use many processors
cores=35#
cl <- makeCluster(35, outfile = "") #not to overload your computer
# outfile as empty prevents doparallel from redirecting the outputs
registerDoParallel(cl)
#registerDoParallel(cores=(Sys.getenv("SLURM_NTASKS_PER_NODE")))

tidy_hansard <- foreach(m = isplitRows(hansard, chunks=35), .combine='rbind',
                       .packages='tidytext') %dopar% {
                         unnest_tokens(m, ngrams, text, token = "ngrams", n = j)
                       }


dir <- setwd("~/")
write_csv(tidy_hansard, file.path(dir, "tokenized_hansard.csv"))


test <- sample_n(tidy_hansard, 10)
