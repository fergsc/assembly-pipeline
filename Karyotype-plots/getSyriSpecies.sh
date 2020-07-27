#!/bin/bash

#find all syri files for all species and save list under species name.

DIR=/g/data/xe2/scott/assembly/syri/out

species=`find /g/data/xe2/scott/assembly/syri/out -name '*.out' | awk '{n = split($0,a,"/"); split(a[n],b,"~"); split(b[2],c,"."); print b[1]; print c[1]} ' | sort | uniq | grep -v 'Egrandis_297'`

for currSpecies in $species
do
    echo "ls -1 $DIR | grep \"${currSpecies}\" | grep -v 'Egrandis_297' | sed -e 's/.out//g' > ${currSpecies}.lst"
#   echo "ls -1 $DIR | grep \"${currSpecies}\" | grep -v 'Egrandis_297' > ${currSpecies}.lst"
done

