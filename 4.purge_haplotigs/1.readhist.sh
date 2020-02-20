#!/bin/bash

if [ -f purge_assemblies.lst ]; then
    echo "purge_assemblies.lst exist - proceed"
else 
    echo "purge_assemblies.lst does not exist and will be created. You should edit this, then rerun."
    find . -name 'keep.fasta' > purge_assemblies.lst
	exit 0
fi


pwd=`pwd`
for assembly in `cat purge_assemblies.lst`
do
	cd "$pwd"
	# find contamination.bam
	dirPurge=$(dirname "${assembly}")
	bam=`find $dirPurge -name '*.bam'`
	bamName=$(basename "$bam")

	# location of assembly
	save=${dirPurge%/*}
	
	# find assembly name
	assemblyName=`echo $save | cut -d / -f 2`
	echo $assemblyName

	# set up directory to save purging to and make pbs script
	cd "$pwd/$save"
	mkdir 3.purge_haplotigs
	cd 3.purge_haplotigs

	touch purge_readhist.pbs

	echo '#!/bin/bash' >> purge_readhist.pbs
	echo "#PBS -P xe2" >> purge_readhist.pbs
	echo "#PBS -q normal" >> purge_readhist.pbs
	echo "#PBS -l walltime=24:00:00" >> purge_readhist.pbs
	echo "#PBS -l mem=48G" >> purge_readhist.pbs
	echo "#PBS -l jobfs=400GB" >> purge_readhist.pbs
	echo "#PBS -l ncpus=12" >> purge_readhist.pbs
	echo "#PBS -l storage=scratch/xe2+gdata/xe2" >> purge_readhist.pbs
	echo "#PBS -l wd" >> purge_readhist.pbs
	echo "#PBS -N $assemblyName" >> purge_readhist.pbs
	echo "" >> purge_readhist.pbs
	echo "set -euo pipefail # safe mode" >> purge_readhist.pbs
	echo "set -x # logging" >> purge_readhist.pbs
	echo "" >> purge_readhist.pbs
	echo 'eval "$(/g/data/xe2/gadi/conda/bin/conda shell.zsh hook)" ##useconda' >> purge_readhist.pbs
	echo "conda activate genome-assembly" >> purge_readhist.pbs
	echo "" >> purge_readhist.pbs

	echo "cp $pwd/$bam* \${PBS_JOBFS}" >> purge_readhist.pbs
	echo "cp $pwd/$assembly \${PBS_JOBFS}" >> purge_readhist.pbs
	echo "" >> purge_readhist.pbs

	echo "purge_haplotigs  hist  -b \${PBS_JOBFS}/$bamName  -g \${PBS_JOBFS}/keep.fasta -t 12 " >> purge_readhist.pbs

	echo "" >> purge_readhist.pbs

	qsub purge_readhist.pbs
done
