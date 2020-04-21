fnaLocation=/g/data/xe2/scott/assembly/chloroplast-unicycler/chloroplasts

for fna in ../*.fasta
do
   fnaFile=$(basename $fna)
   species=${fnaFile%_*}
   echo "$species"
   mkdir $species
   cd $species
   nucmer --maxmatch ../NCBI-grandis-10k.fasta ${fnaLocation}/${fnaFile} &> nucmer.log
   show-coords -THrd out.delta > out.coords

   # get new start position
   best=`cut -f6 out.coords | sort -hr | head -n 1`
   start=`grep $best out.coords | cut -f3`

   # make new fasta with new start position, get header, then rotate sequence
   grep '^>' ${fnaLocation}/${fnaFile} > ../${fnaFile}
   grep -v '^>' ${fnaLocation}/${fnaFile} | tr -d '\n' > temp.fasta
   cut -c ${start}- temp.fasta >start.fasta
   cut -c -$[start-1] temp.fasta >end.fasta
   cat start.fasta end.fasta | tr -d '\n' >> ../${fnaFile}

   cd ..
done
