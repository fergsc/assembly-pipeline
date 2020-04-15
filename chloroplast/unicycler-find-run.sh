#/bin/bash

if [ -f species.lst ]; then
    echo "species.lst exist - proceed"
else
    echo "species.lst does not exist and will be created. You should edit this, then rerun."
    find /g/data/xe2/scott/assembly/fastq -name '*final.fastq*' | sort -h > species.lst
    exit 0
fi

pwd=`pwd`
chlorFna=chloroplast_composite.fasta
chloroDir=/g/data/xe2/scott/assembly/chloroplast-unicycler

for fna in `cat species.lst`
do
   cd $pwd

   fnaFile=$(basename $fna)
   species="${fnaFile%_final.fastq.gz}"
   echo $fnaFile $species

   mkdir $species
   cd $species

   echo "#!/bin/bash" > unicycler.pbs
   echo "#PBS -P xe2" >> unicycler.pbs
   echo "#PBS -q normal" >> unicycler.pbs
   echo "#PBS -l walltime=12:00:00" >> unicycler.pbs
   echo "#PBS -l mem=16G" >> unicycler.pbs
   echo "#PBS -l jobfs=300GB" >> unicycler.pbs
   echo "#PBS -l ncpus=4" >> unicycler.pbs
   echo "#PBS -l storage=gdata/xe2" >> unicycler.pbs
   echo "#PBS -l wd" >> unicycler.pbs
   echo "" >> unicycler.pbs
   echo "set -euo pipefail # safe mode" >> unicycler.pbs
   echo "set -x # logging" >> unicycler.pbs
   echo "" >> unicycler.pbs
   echo "set +u" >> unicycler.pbs
   echo 'eval "$(/g/data/xe2/gadi/conda/bin/conda shell.zsh hook)"' >> unicycler.pbs
   echo "conda activate Unicycler" >> unicycler.pbs
   echo "set -u" >> unicycler.pbs
   echo "module load samtools/1.9" >> unicycler.pbs
   echo "" >> unicycler.pbs

   echo "pwd=`pwd`" >> unicycler.pbs
   echo "cp ${fna} \${PBS_JOBFS}" >> unicycler.pbs
   echo "cp ${chloroDir}/${chlorFna} \${PBS_JOBFS}" >> unicycler.pbs
   echo "cd \${PBS_JOBFS}" >> unicycler.pbs
   echo "" >> unicycler.pbs
   echo "/g/data/xe2/scott/gadi_modules/minimap2_2.17_cascade/minimap2 -t \${PBS_NCPUS} -ax map-ont ${chlorFna} ${fnaFile} | \\" >> unicycler.pbs
   echo "   samtools view -F 4 > only_mapped_reads.sam" >> unicycler.pbs
   echo "cp only_mapped_reads.sam \${pwd}" >> unicycler.pbs
   echo "" >> unicycler.pbs
   echo "grep -v '^@' only_mapped_reads.sam | cut -f1 | sort | uniq > chloro_read_names.lst" >> unicycler.pbs
   echo "/g/data/xe2/scott/gadi_modules/seqtk/seqtk subseq ${fnaFile} chloro_read_names.lst > chloro_reads.fastq" >> unicycler.pbs
   echo "cp chloro_read_names.lst \${pwd}" >> unicycler.pbs
   echo "cp chloro_reads.fastq \${pwd}" >> unicycler.pbs
   echo "" >> unicycler.pbs

   echo "/g/data/xe2/scott/gadi_modules/seqtk/seqtk sample -s55 chloro_reads.fastq 1000 > chloro_reads_1000.fastq" >> unicycler.pbs
   echo "cp chloro_reads_1000.fastq \${pwd}" >> unicycler.pbs
   echo "" >> unicycler.pbs

   echo "unicycler -l chloro_reads_1000.fastq -o unicycler-long -t \${PBS_NCPUS}" >> unicycler.pbs
   echo "cp -r unicycler-long \${pwd}" >> unicycler.pbs
   echo "" >> unicycler.pbs

   qsub unicycler.pbs
   cd ..
done

