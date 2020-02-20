#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

stopifnot(length(args)==1)

print(args)

N50 = function(contigs, n=50)
{
  contigs = rev(sort(contigs))
  runningTotal = cumsum(contigs)
  half = sum(contigs) * (n/100)
  return(contigs[max(which(runningTotal <= half)+1)])
}

print(N50(read.table(args)$V2))



