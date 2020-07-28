#!/bin/bash

for gff in `find /g/data/xe2/scott/assembly/EDTA -name '*EDTA.TEanno.gff'`
do
    tmp=$(basename $gff);species=`echo $tmp | cut -f1 -d'.'`

    [ -f "${species}.te" ] && continue

    echo ${species}
    grep -v '^#' ${gff} | cut -f1,4,5 > ${species}.te
done
