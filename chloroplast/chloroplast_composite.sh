for fullfilename in *.fasta
do
   echo ${fullfilename}

   grep '^>' ${fullfilename} >> chloroplast_composite.fasta  #copy header into concatinated fasta
   grep -v '^>' ${fullfilename} > temp #copy everything but header temp file

   tr -d '\n' < temp > temp2 #remove all new lines

   cat temp2 >> chloroplast_composite.fasta # copy sequence into concate fasta twice
   cat temp2 >> chloroplast_composite.fasta

   sed -i -e '$a\' chloroplast_composite.fasta # add a new line for new species
done
 
rm temp temp2
