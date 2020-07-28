#!/bin/bash

awk -v OFS='\t' '{if($3 == "gene"){split($9,a,";"); if($4<$5){print $1,$4,$5,a[1]} else {print $1,$5,$4,a[1]}}}' XXX.gtf > XXX.genes
