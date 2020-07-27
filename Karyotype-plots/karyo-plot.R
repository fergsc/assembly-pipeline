#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
stopifnot(length(args)==1)
species = strsplit(args, ".scr")[1]


library(data.table)
library(karyoploteR)

genomeFile = fread(sprintf("/home/scott/pangenome/summary_plots/gne-files/%s.genome", species), col.names = c("Chromosome", "Size"))
syriScores = fread(args)

currGenome = toGRanges(data.frame(chr = genomeFile$Chromosome, start = rep(1, dim(genomeFile)[1]), end = genomeFile$Size))

svg(sprintf("%s.svg", species), width = 20, height = 10)
kp = plotKaryotype(genome = currGenome, main = species, plot.type=1)
kpDataBackground(kp, data.panel = 1, r0 = 0, r1 = 0.48)
kpDataBackground(kp, data.panel = 2, r0 = 0.52, r1 = 1)
#kpAddBaseNumbers(kp, tick.dist = 10000000, tick.len = 10, tick.col="red", cex=1,
#                      minor.tick.dist = 1000000, minor.tick.len = 5, minor.tick.col = "gray", add.units=TRUE)
kpAxis(kp, ymin=0, ymax=22, cex=0.5, data.panel = 1, r0 = 0, r1 = 0.45) #, col="gray50", cex=0.5)
kpAxis(kp, ymin=0, ymax=22, cex=0.5, data.panel = 1, r0 = 0.55, r1 = 1)

#test = toGRanges(data.frame(chr = syriScores$chromosome, start = syriScores$chromosome))
kpLines(kp, chr = syriScores$chromosome, col="red", x = syriScores$genomeIndex, y = syriScores$SYN/22,
        data.panel = 1, r0 = 0, r1 = 0.48)
#kpLines(kp, chr = syriScores$chromosome, col="blue", x = syriScores$genomeIndex, y = syriScores$NOTAL/22)
kpLines(kp, chr = syriScores$chromosome, col="blue", x = syriScores$genomeIndex, y = syriScores$REARRANGED/22,
        data.panel = 2, r0 = 0.52, r1 = 1)

kpText(kp, chr=genomeFile$Chromosome, x=genomeFile$Size+1500000, y=0.1, col="red", r0=0.20, r1=0, labels="Syntenic")
kpText(kp, chr=genomeFile$Chromosome, x=genomeFile$Size+2200000, y=0.1, col="blue", r0=0.70, r1=0, labels="Re-arranged")
dev.off()
