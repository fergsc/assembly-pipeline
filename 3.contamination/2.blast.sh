#!/bin/bash

#
# Want to subdivide assembly fasta into smaller pieces (12).
# Do blast on each subdivision seperately ni parallel.
# Allowing us to blast our assembly in a timely manner.
#
# We first find all assemblies (*.contigs.fasta)
# Get the total number of contigs.
# Segment assembly into 12 fasta files.
# Create a pbs script to balst these segemnts
# Job runs on 12 processors.
#


if [ -f assembly.lst ]; then
    echo "assembly.lst exist - proceed"
else 
    echo "assembly.lst does not exist and will be created. You should edit this, then rerun."
    touch assembly.lst
	for fna in `find $1 -name '*.contigs.fasta'`
	do
		echo $fna >> assembly.lst
	done
	exit 0
fi


for fna in `cat assembly.lst`
do
filenameExt=$(basename "$fna")
filename="${filenameExt%.*}"
dir=$(dirname "${fna}")
save=${dir%/*}

cd $dir
mkdir 2.blast_contamination #$save/
cd 2.blast_contamination #$save/

bioawk -c fastx '{print $name}' $fna > contigs.all

total=`wc -l contigs.all | cut -d ' ' -f1`
div=$((total/12))
	
for i in {0..11}
do
	START=$(($i * $div))
	END=$(($i * $div + $div - 1))

	if (($i == 0))
	then
	START=1
	END=$((div -1))
	fi

	if (($i == 11))
	then
	END=$total
	fi

    sed -n "${START},${END}p" < contigs.all > breaks_$((i+1)).lst

done


for file in *.lst
do
	tmpExt=$(basename "$file")
	tmpFilename="${tmpExt%.*}"

	seqtk subseq $fna $file > $tmpFilename.fasta
done

RUN=""
for file in *.fasta
do
	tmpExt=$(basename "$file")
	tmpFilename="${tmpExt%.*}"
	    
    RUN=$RUN' & blastn -query ${PBS_JOBFS}/'$file' -db /scratch/xe2/sf3809/NCBIDB/nt  -outfmt "6 qseqid staxids bitscore std" -max_target_seqs 10 -max_hsps 1 -evalue 1e-25 -out blast_bits/'$tmpFilename'.out'
done

touch contamination_blast.pbs

echo "#!/bin/bash" >> contamination_blast.pbs
echo "#PBS -P xe2" >> contamination_blast.pbs
echo "#PBS -q normal" >> contamination_blast.pbs
echo "#PBS -l walltime=48:00:00" >> contamination_blast.pbs
echo "#PBS -l mem=48G" >> contamination_blast.pbs
echo "#PBS -l jobfs=400GB" >> contamination_blast.pbs
echo "#PBS -l ncpus=12" >> contamination_blast.pbs
echo "#PBS -l storage=scratch/xe2+gdata/xe2" >> contamination_blast.pbs
echo "#PBS -l wd" >> contamination_blast.pbs
echo "#PBS -N $filename" >> contamination_blast.pbs
echo "" >> contamination_blast.pbs
echo "set -euo pipefail # safe mode" >> contamination_blast.pbs
echo "set -x # logging" >> contamination_blast.pbs
echo "" >> contamination_blast.pbs
echo 'eval "$(/g/data/xe2/gadi/conda/bin/conda shell.zsh hook)" ##useconda' >> contamination_blast.pbs
echo "conda activate genome-assembly" >> contamination_blast.pbs
echo "" >> contamination_blast.pbs

echo 'cp *.fasta ${PBS_JOBFS}' >> contamination_blast.pbs
echo "mkdir blast_bits" >> contamination_blast.pbs
echo "" >> contamination_blast.pbs

echo $RUN | cut -c 3- >> contamination_blast.pbs
echo "" >> contamination_blast.pbs

echo "cat blast_bits/*.out > blast.out" >> contamination_blast.pbs
echo "" >> contamination_blast.pbs

rm *.lst *.all

# finally run the blast!!!
qsub contamination_blast.pbs
done

