#!/bin/bash

# to make plots
## python busco3/scripts/generate_plot.py --working_directory E_melliodora
#

LINEAGES=/scratch/xe2/sf3809/eudicots_odb10

 
if [ -f fasta.lst ]; then
    echo "fasta.lst exist - proceed"
else 
    echo "fasta.lst does not exist and will be created. You should edit this, then rerun."
    touch fasta.lst

	#
	# change this so that it finds the cprrect genomes to BUSCO.
	#
	
	# raw
	# find /g/data/xe2/scott/assembly -name '*.contigs.fasta' > fasta.lst

	# raw and contamination filtered
	find /g/data/xe2/scott/assembly -name 'keep.fasta' > fasta.lst
 	
	# purged
	#find /g/data/xe2/scott/assembly -name 'curated.fasta' > fasta.lst

	# final polished
    #ls -1 /g/data/xe2/scott/assembly/genomes/*.fasta > fasta.lst
        
	exit 0
fi


for fna in `cat fasta.lst`
do
	nameExt=$(basename "$fna")
	name="${nameExt%.*}"
	echo $name

	echo "#!/bin/bash" > $name.pbs
	echo "#PBS -P xe2" >> $name.pbs
	echo "#PBS -q normal" >> $name.pbs
	echo "#PBS -l walltime=48:00:00" >> $name.pbs
	echo "#PBS -l mem=16GB" >> $name.pbs
	echo "#PBS -l jobfs=10GB" >> $name.pbs
	echo "#PBS -l ncpus=6" >> $name.pbs
	echo "#PBS -l storage=scratch/xe2+gdata/xe2" >> $name.pbs
	echo "#PBS -l wd" >> $name.pbs
	echo "#PBS -N $name" >> $name.pbs
	echo "" >> $name.pbs
	echo "set -euo pipefail # safe mode" >> $name.pbs
	echo "set -x # logging" >> $name.pbs
	echo "" >> $name.pbs
	echo 'set +u' >> $name.pbs
	echo 'eval "$(/g/data/xe2/gadi/conda/bin/conda shell.zsh hook)" ##useconda' >> $name.pbs
	echo "conda activate busco" >> $name.pbs
	echo 'set -u' >> $name.pbs
	echo "" >> $name.pbs

	echo "cp $fna \${PBS_JOBFS}"  >> $name.pbs
	echo "" >> $name.pbs	

	echo "python /g/data/xe2/gadi/conda/envs/busco/bin/busco \\" >> $name.pbs
	echo "  -i \${PBS_JOBFS}/$nameExt \\" >> $name.pbs
  	echo "  -o $name \\" >> $name.pbs
	echo "  -l $LINEAGES -m geno -c \${PBS_NCPUS}" >> $name.pbs
done
