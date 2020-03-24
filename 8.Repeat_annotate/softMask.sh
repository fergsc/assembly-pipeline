module load bedtools/2.28.0

for fna in `ls /g/data/xe2/scott/assembly/genomes/RaGOO-masked/*.fasta`
do
   fnaFile=$(basename $fna)
   regions=`find /g/data/xe2/scott/assembly/genomes/RaGOO-masked -name "${fnaFile}.out" `

   sed -e '1,3d' $regions | awk -v OFS='\t' '{print $5, $6, $7}' > mask_regions.bed
   echo $fnaFile $regions
   bedtools maskfasta -soft -fi $fna -bed mask_regions.bed -fo $fnaFile
done

module unload bedtools/2.28.0
