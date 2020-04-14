#!/bin/bash

if [ -f softMask.lst ]; then
    echo "softMask.lst exist - proceed"
else
    echo "softMask.lst does not exist and will be created. You should edit this, then rerun."
    ls /g/data/xe2/scott/assembly/genomes/RaGOO/*.fasta | sort -h > softMask.lst
    exit 0
fi

module load bedtools/2.28.0

for fna in `cat softMask.lst`
do
   fnaFile=$(basename $fna)
   regions=`find /g/data/xe2/scott/assembly/genomes/RaGOO-hard -name "${fnaFile}.out" `
   echo $fnaFile $regions

   sed -e '1,3d' $regions | awk -v OFS='\t' '{print $5, $6-1, $7}' > mask_regions.bed
   bedtools maskfasta -soft -fi $fna -bed mask_regions.bed -fo $fnaFile
done

module unload bedtools/2.28.0
