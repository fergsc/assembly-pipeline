#!/bin/bash

pwd=`pwd`
for csv in purge_histograms/csv/*.csv
do
	cd $pwd

	#get name of assembly we are processing
	tmp=$(basename "$csv")
	name="${tmp%.*}"

	#find location of fatsa to process
	assembly=`find . -name 'keep.fasta' | grep $name`

	#get cutoff values from csv for purging.
	low=`cut -d , -f 1 $csv`
	mid=`cut -d , -f 2 $csv`
	high=`cut -d , -f 3 $csv`

	#get working directory and change to
	dir=`echo $assembly | awk '{split($0,a,"/"); print a[2] "/" a[3] "/3.purge_haplotigs"}'`
	cd "$dir"

	# write out pbs script to remove haps.

	echo '#!/bin/bash' >> purge_purge.pbs
	echo "#PBS -P xe2" >> purge_purge.pbs
	echo "#PBS -q normal" >> purge_purge.pbs
	echo "#PBS -l walltime=30:00:00" >> purge_purge.pbs
	echo "#PBS -l mem=16GB" >> purge_purge.pbs
	echo "#PBS -l jobfs=400GB" >> purge_purge.pbs
	echo "#PBS -l ncpus=4" >> purge_purge.pbs
	echo "#PBS -l storage=scratch/xe2+gdata/xe2" >> purge_purge.pbs
	echo "#PBS -l wd" >> purge_purge.pbs
	echo "#PBS -N $name" >> purge_purge.pbs
	echo "" >> purge_purge.pbs
	echo "set -euo pipefail # safe mode" >> purge_purge.pbs
	echo "set -x # logging" >> purge_purge.pbs
	echo "" >> purge_purge.pbs
	echo "set +u" >> purge_purge.pbs
	echo 'eval "$(/g/data/xe2/gadi/conda/bin/conda shell.zsh hook)" ##useconda' >> purge_purge.pbs
	echo "conda activate genome-assembly" >> purge_purge.pbs
	echo "set -u" >> purge_purge.pbs
	echo "" >> purge_purge.pbs

	echo "cp $pwd/$assembly \${PBS_JOBFS}" >> purge_purge.pbs
	echo "cp ../2.blast_contamination/sorted_mapped_reads.bam* \${PBS_JOBFS}" >> purge_purge.pbs
	echo "cp sorted_mapped_reads.bam.gencov \${PBS_JOBFS}" >> purge_purge.pbs
	echo "" >> purge_purge.pbs

	echo "purge_haplotigs  contigcov  -i \${PBS_JOBFS}/sorted_mapped_reads.bam.gencov  -l $low  -m $mid  -h $high" >> purge_purge.pbs
	echo "purge_haplotigs  purge  -g \${PBS_JOBFS}/keep.fasta -c coverage_stats.csv -b \${PBS_JOBFS}/sorted_mapped_reads.bam -d -t 4" >> purge_purge.pbs
	echo "" >> purge_purge.pbs

	qsub purge_purge.pbs
done
