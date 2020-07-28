import sys
import csv
import math
import ntpath

WINDOW = 5000
GENOME_DIR = "/g/data/xe2/scott/assembly/syri/genomes/gne-files"
#GENOME_DIR = "/home/scott/pangenome/summary_plots/gne-files"

chroms = ["Chr01", "Chr02", "Chr03", "Chr04", "Chr05", "Chr06", "Chr07", "Chr08", "Chr09", "Chr10", "Chr11"]

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

def loadGenes(filename):
    tsv_file = open(filename, "r")
    geneFile = csv.reader(tsv_file, delimiter="\t")
    chr01=[]
    chr02=[]
    chr03=[]
    chr04=[]
    chr05=[]
    chr06=[]
    chr07=[]
    chr08=[]
    chr09=[]
    chr10=[]
    chr11=[]
    for gene in geneFile:
        chrom = gene[0]
        start = gene[1]
        end = gene[2]
        geneId = gene[3]
        if chrom == "Chr01":
            chr01.append([geneId, int(start), int(end)])
        if chrom == "Chr02":
            chr02.append([geneId, int(start), int(end)])
        if chrom == "Chr03":
            chr03.append([geneId, int(start), int(end)])
        if chrom == "Chr04":
            chr04.append([geneId, int(start), int(end)])
        if chrom == "Chr05":
            chr05.append([geneId, int(start), int(end)])
        if chrom == "Chr06":
            chr06.append([geneId, int(start), int(end)])
        if chrom == "Chr07":
            chr07.append([geneId, int(start), int(end)])
        if chrom == "Chr08":
            chr08.append([geneId, int(start), int(end)])
        if chrom == "Chr09":
            chr09.append([geneId, int(start), int(end)])
        if chrom == "Chr10":
            chr10.append([geneId, int(start), int(end)])
        if chrom == "Chr11":
            chr11.append([geneId, int(start), int(end)])
    tsv_file.close()
    return [chr01, chr02, chr03, chr04, chr05, chr06, chr07, chr08, chr09, chr10, chr11]

##########
### get species name
genesFile = sys.argv[1]
species = ntpath.basename(genesFile).split(".")[0]

##########
### read in gene list file
genesList = loadGenes(genesFile)


##########
### read in genome file
with open("{}/{}.genome".format(GENOME_DIR, species)) as f:
    genome = f.read().splitlines()
genome = [(x.split("\t")) for x in genome]

##########
### cycle through genes and add to score matrix
fileHeader = False
for index, currChrom in enumerate(chroms):
    ##########
    ### initialise score vector
    score = [0] * getGenomeSize(genome, currChrom)
    for currGene in genesList[index]:
        if currGene[1] > currGene[2]:
            currGene[1], currGene[2] = currGene[2], currGene[1]
        score[currGene[1]:currGene[2]] = incrementList(score[currGene[1]:currGene[2]])

    ##########
    ### save results
    score = ScoreRegions(score, WINDOW)
    if fileHeader == False:
        fileHeader = True
        with open("{}-{}.gd".format(WINDOW, species), "w") as outfile:
            outfile.write("chromosome,genomeIndex,geneDensity\n")
    with open("{}-{}.gd".format(WINDOW, species), "a") as outfile:
        genomeIndex = int(WINDOW/2)
        for n in range(0, len(score)):
            outfile.write("{},{},{}\n".format(currChrom, genomeIndex, score[n]))
            genomeIndex = genomeIndex + WINDOW

