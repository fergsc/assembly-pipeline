#!bin/bash

if [ -f repeat.lst ]; then
    echo "repeat.lst exist - proceed"
else
    echo "repeat.lst does not exist and will be created. You should edit this, then rerun."
    touch repeat.lst

    ls -1 /g/data/xe2/scott/assembly/genomes/*.fasta > repeat.lst
    exit 0
fi

for genome in `cat repeat.lst`
do
   fileName=$(basename "$genome")
   species=${fileName%.fasta}

   echo "#!/bin/bash" >> $species.pbs
   echo "#PBS -P xe2" >> $species.pbs
   echo "#PBS -q normal" >> $species.pbs
   echo "#PBS -l walltime=48:00:00" >> $species.pbs
   echo "#PBS -l mem=32GB" >> $species.pbs
   echo "#PBS -l jobfs=400GB" >> $species.pbs
   echo "#PBS -l ncpus=8" >> $species.pbs
   echo "#PBS -l storage=gdata/xe2" >> $species.pbs
   echo "#PBS -l wd" >> $species.pbs
   echo "" >> $species.pbs
   echo "set -euo pipefail # safe mode" >> $species.pbs
   echo "set -x # logging" >> $species.pbs
   echo "" >> $species.pbs
   echo "set +u" >> $species.pbs
   echo 'eval "$(/g/data/xe2/gadi/conda/bin/conda shell.zsh hook)" ##useconda' >> $species.pbs
   echo "conda activate EDTA" >> $species.pbs
   echo "set -u" >> $species.pbs
   echo "" >> $species.pbs
   echo "mkdir \${PBS_JOBFS}/$species" >> $species.pbs
   echo "cp $genome \${PBS_JOBFS}/$species" >> $species.pbs
   echo "cd \${PBS_JOBFS}/$species" >> $species.pbs
   echo "" >> $species.pbs
   echo "/g/data/xe2/scott/gadi_modules/EDTA/EDTA.pl --genome $fileName --anno 1 --threads \${PBS_NCPUS}" >> $species.pbs
   echo "" >> $species.pbs
   echo "rm $fileName" >> $species.pbs
   echo "mv \${PBS_JOBFS}/$species `pwd`" >> $species.pbs
   
   qsub $species.pb
done
