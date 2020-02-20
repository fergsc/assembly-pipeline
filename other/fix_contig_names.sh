#!/bin/bash

#########
# As a result of pilon polishing, contig names are contigXXX_pilon_pilon_etc
# Need to remove all the _pilon from names.
#
# Also use this to save genomes in a common directory
#########

if [ -f genome.lst ]; then
    echo "genome.lst exist - proceed"
else 
    echo "genome.lst does not exist and will be created. You should edit this, then rerun."
    touch genome.lst

    find /g/data/xe2/scott/assembly -wholename '*5/pilon.fasta' >> genome.lst
	exit 0
fi

for fna in `cat genome.lst`
do
	name=`echo $fna | cut -d / -f 7`
	echo $name

	awk '{if($0 ~ ">") { split($0,a,"_pilon"); print a[1]} else print $0}' $fna > $name.fasta

done
