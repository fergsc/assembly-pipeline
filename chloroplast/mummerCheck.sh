for fna in ../*.fasta
do
   tmp=$(basename $fna)
   species=${tmp%_*}
   
   nucmer --maxmatch NCBI_table.fasta $fna -p $species
   mummerplot --layout --large -filter -png -p $species ${species}.delta 
done
