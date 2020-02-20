#!/bin/bash

touch curated_lengths.csv
for fna in `find . -name '3.purge_haplotigs'`
do
	name=`echo $fna | cut -d / -f 2`

	echo "$name" > tmp.lengths
	bioawk -c fastx '{print length($seq)}' $fna/curated.fasta >> tmp.lengths

	paste -d , curated_lengths.csv tmp.lengths > tmp.csv
	rm curated_lengths.csv tmp.lengths
	mv tmp.csv curated_lengths.csv
done
