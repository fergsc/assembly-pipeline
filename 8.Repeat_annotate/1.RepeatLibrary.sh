#!/bin/bash

# /scratch/xe2/workspaces/alleucs/reads/samples all these are gz.
#/g/data/xe2/scott/gadi_modules/pilon-1.23.jar
# need to load perl?

if [ -f repeat.lst ]; then
    echo "repeat.lst exist - proceed"
else 
    echo "repeat.lst does not exist and will be created. You should edit this, then rerun."
    touch repeat.lst

    find . -wholename '*5/pilon.fasta' >> repeat.lst
    exit 0
fi

pwd=`pwd`
for fna in `cat repeat.lst`
do
	#reset
	cd $pwd

	#get species name and direcetory to save to.
    species=`echo $fna | cut -d / -f 2`
    tmp=`echo $fna | cut -d / -f 3`
    baseDir="$species/$tmp"
    fastaFile=$(basename "$fna")

    # make and go to working directory
    cd $baseDir
    mkdir -p 6.repeats
    cd 6.repeats

# could cut this out and just run on longin node.
# BuildDatabase ~= 3mins.


	echo "#!/bin/bash" > repeat1.pbs
	echo "#PBS -P xe2" >> repeat1.pbs
	echo "#PBS -q normal" >> repeat1.pbs
	echo "#PBS -l walltime=1:00:00" >> repeat1.pbs
	echo "#PBS -l mem=4G" >> repeat1.pbs
	echo "#PBS -l jobfs=400GB" >> repeat1.pbs
	echo "#PBS -l ncpus=1" >> repeat1.pbs
	echo "#PBS -l storage=gdata/xe2" >> repeat1.pbs
	echo "#PBS -N $species" >> repeat1.pbs
	echo "#PBS -l wd" >> repeat1.pbs
	echo "" >> repeat1.pbs

	echo "set -euo pipefail # safe mode" >> repeat1.pbs
	echo "set -x # logging" >> repeat1.pbs

	echo "set +u" >> repeat1.pbs
	echo 'eval "$(/g/data/xe2/gadi/conda/bin/conda shell.zsh hook)"' >> repeat1.pbs
	echo "conda activate rm_test" >> repeat1.pbs
	echo "set -u" >> repeat1.pbs
	echo "" >> repeat1.pbs

	echo "cp ${pwd}/${fna} \${PBS_JOBFS}" >> repeat1.pbs
	echo "BuildDatabase -name ${species} -engine ncbi \${PBS_JOBFS}/${fastaFile}" >> repeat1.pbs
	echo "" >> repeat1.pbs
	echo "qsub repeat2.pbs" >> repeat1.pbs
	echo "" >> repeat1.pbs


# do need this. Takes long time.

	echo "#!/bin/bash" > repeat2.pbs
	echo "#PBS -P xe2" >> repeat2.pbs
	echo "#PBS -q normal" >> repeat2.pbs
	echo "#PBS -l walltime=48:00:00" >> repeat2.pbs
	echo "#PBS -l mem=32G" >> repeat2.pbs
	echo "#PBS -l jobfs=10GB" >> repeat2.pbs
	echo "#PBS -l ncpus=8" >> repeat2.pbs
	echo "#PBS -l storage=gdata/xe2" >> repeat2.pbs
	echo "#PBS -N $species" >> repeat2.pbs
	echo "#PBS -l wd" >> repeat2.pbs
	echo "" >> repeat2.pbs

	echo "set -euo pipefail # safe mode" >> repeat2.pbs
	echo "set -x # logging" >> repeat2.pbs

	echo "set +u" >> repeat2.pbs
	echo 'eval "$(/g/data/xe2/gadi/conda/bin/conda shell.zsh hook)"' >> repeat2.pbs
	echo "conda activate rm_test" >> repeat2.pbs
	echo "set -u" >> repeat2.pbs
	echo "" >> repeat2.pbs

	echo "RepeatModeler -engine ncbi -database ${species} -pa \${PBS_NCPUS}" >> repeat2.pbs
	echo "" >> repeat2.pbs

	qsub repeat1.pbs
done
