mkdir -p fasta

for fna in `find . -name 'assembly.fasta'`
do
   species=`echo $fna | cut -f2 -d'/'`
   echo $species

   cp ${fna} fasta1/${species}_chloroplast.fasta
   bioawk -c fastx '{print $name, length($seq)}' ${fna} > fasta1/${species}_chloroplast.genome
   echo "$species" >> fasta1/all.genome
   bioawk -c fastx '{print $name, length($seq)}' ${fna} >> fasta1/all.genome
   echo "" >> fasta1/all.genome
done

mkdir -p gfa1

for gfa in `find . -name 'assembly.gfa'`
do
   species=`echo $gfa | cut -f2 -d'/'`
   echo $species

   cp ${gfa} gfa1/${species}_chloroplast.gfa
done
