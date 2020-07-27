import sys
import csv
import math
#import numpy as np

#import ntpath

WINDOW = 10000
NUM_COMPARISONS = 20
SYRI_DIR = "/g/data/xe2/scott/assembly/syri/SyRI"
GENOME_DIR = "/g/data/xe2/scott/assembly/syri/genomes/gne-files"
#SYRI_DIR = "/home/scott/pangenome/summary_plots/E_viminalis"
#GENOME_DIR = "/home/scott/pangenome/summary_plots/gne-files"

def fillCoords(base, index):
    return base * index

def incrementList(list, x = 1):
    '''
    Add a score, default 1
    to the pased in list.
    '''
    xxx = []
    for n in list:
        xxx.append(n + x)
    return xxx

def ScoreRegions(results, stepSize):
    '''
    take the raw results for a whole chromosome
    and break it down into a windowed score (mean, round up).
    '''
    scores = [0] * int(round((len(results)/stepSize) +0.5, 0)) # +0.5
    inRation = int(stepSize/2) # want this to round down, use int not ceil
    for n, start in enumerate(range(0, len(results), stepSize)):
        end = start + stepSize
        scores[n] = int(round((sum(results[start:end]) / stepSize), 0))
    return scores

def getGenomeSize(chromosomes, chr):
    '''
    Takes in the genome file and returns the
    chromosome size of the requested chromosome
    '''
    for x in chromosomes:
        if (x[0] == chr):
            return int(x[1])

# read in SyRI list file
syriListFile = sys.argv[1]
species = syriListFile.split(".")[0]

with open(syriListFile) as f:
    syriList = f.read().splitlines()

# setup chromosomes
chroms = ["Chr01", "Chr02", "Chr03", "Chr04", "Chr05", "Chr06", "Chr07", "Chr08", "Chr09", "Chr10", "Chr11"]

##########
### read in genome file
### set up score matrix
with open("{}/{}.genome".format(GENOME_DIR, species)) as f:
    genome = f.read().splitlines()
genome = [(x.split("\t")) for x in genome]

#scores = []
#for c in chroms:
#    for x in genome:
#        if x[0] == c:
#            scores.append([0] * int(x[1]))

#scores = [[0] * int(x[1]) for x in genome]
#print("scoresLen:{}".format(len(scores)))

fileHeader = False
##########
### loop over chromosomes and score each one
for index, currChrom in enumerate(chroms):
    #print("Chrom:{}".format(currChrom))
    # get chromosome size & build score list
    gSize = getGenomeSize(genome, currChrom)
    scoreSYN = [0] * gSize
    scoreNOTAL = [0] * gSize
    scoreREARRANGED = [NUM_COMPARISONS] * gSize

    # loop through all syri comparisons
    for currComparison in syriList:

        syriRef = currComparison.split("~")[0]
        syriQry = currComparison.split("~")[1]

        #print(currComparison)
        #print(species)
        #print(syriRef)
        #print(syriQry)
        if species == syriRef:
            #print("reference")
            chrIndex = 0
            startIndex = 1
            endIndex = 2
            notalFile = "NOTAL_ref"
        else:
            #print("query")
            chrIndex = 5
            startIndex = 6
            endIndex = 7
            notalFile = "NOTAL_qry"

        ##########
        ### syntenic regions
        tsvFile = open("{}/{}/SYN_{}.out".format(SYRI_DIR, currComparison, currChrom), "r")
        syriEvents = csv.reader(tsvFile, delimiter="\t")

        for event in syriEvents:
            sStart = int(event[startIndex])
            sEnd = int(event[endIndex])
            if sStart > sEnd:
                sStart , sEnd = sEnd, sStart
            scoreSYN[sStart:sEnd] = incrementList(scoreSYN[sStart:sEnd])
            scoreREARRANGED[sStart:sEnd] = incrementList(scoreREARRANGED[sStart:sEnd], -1)
        tsvFile.close()

        ##########
        ### not-aligned regions
        tsvFile = open("{}/{}/{}_{}.out".format(SYRI_DIR, currComparison, notalFile, currChrom), "r")
        syriEvents = csv.reader(tsvFile, delimiter="\t")

        for event in syriEvents:
            sStart = int(event[startIndex])
            sEnd = int(event[endIndex])
            if sStart > sEnd:
                sStart , sEnd = sEnd, sStart
            scoreNOTAL[sStart:sEnd] = incrementList(scoreNOTAL[sStart:sEnd])
            scoreREARRANGED[sStart:sEnd] = incrementList(scoreREARRANGED[sStart:sEnd], -1)
        tsvFile.close()

    ##########
    ### save results
    scoreSYN = ScoreRegions(scoreSYN, WINDOW)
    scoreNOTAL = ScoreRegions(scoreNOTAL, WINDOW)
    scoreREARRANGED = ScoreRegions(scoreREARRANGED, WINDOW)
    if fileHeader == False:
        fileHeader = True
        with open("{}-{}.scr".format(WINDOW, species), "w") as outfile:
            outfile.write("chromosome,genomeIndex,SYN,NOTAL,REARRANGED\n")
    with open("{}-{}.scr".format(WINDOW, species), "a") as outfile:
        genomeIndex = int(WINDOW/2)
        for n in range(0, len(scoreSYN)):
            outfile.write("{},{},{},{},{}\n".format(currChrom, genomeIndex, scoreSYN[n], scoreNOTAL[n], scoreREARRANGED[n]))
            genomeIndex = genomeIndex + WINDOW

