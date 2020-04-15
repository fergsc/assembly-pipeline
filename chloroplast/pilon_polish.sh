#!/bin/bash

for fna in `cat good.lst`
do
    # find short reads to polish with
    tmp=`echo $fna | cut -d _ -f 2`
    reads=`find /scratch/xe2/workspaces/alleucs/reads/samples -name '*.fastq*' | grep $tmp`
    tmp=$(basename "$reads")
    readsFile="${tmp%.*}" # remove the .gz

    if [[ -z $reads ]]
    then
        echo "$fna reads not found: look in /scratch/xe2/workspaces/alleucs/reads/samples"
        reads="/scratch/xe2/workspaces/alleucs/reads/samples"
        readsFile="XXXXX"
    fi

    cd $fna

    echo "#!/bin/bash" > pilon_polish.pbs
    echo "#PBS -P xe2" >> pilon_polish.pbs
    echo "#PBS -q hugemem" >> pilon_polish.pbs
    echo "#PBS -l walltime=30:00:00" >> pilon_polish.pbs
    echo "#PBS -l mem=1000GB" >> pilon_polish.pbs
    echo "#PBS -l jobfs=1000GB" >> pilon_polish.pbs
    echo "#PBS -l ncpus=24" >> pilon_polish.pbs
    echo "#PBS -l storage=scratch/xe2+gdata/xe2" >> pilon_polish.pbs
    echo "#PBS -l wd" >> pilon_polish.pbs
    echo "#PBS -N ${fna}Chloroplast" >> pilon_polish.pbs
    echo "" >> pilon_polish.pbs
    echo "set -euo pipefail # safe mode" >> pilon_polish.pbs
    echo "set -x # logging" >> pilon_polish.pbs
    echo "" >> pilon_polish.pbs
    #echo 'set +u' >> pilon_polish.pbs
    #echo 'eval "$(/g/data/xe2/gadi/conda/bin/conda shell.zsh hook)" ##useconda' >> pilon_polish.pbs
    #echo "conda activate genome-assembly" >> pilon_polish.pbs
    #echo 'set -u' >> pilon_polish.pbs
    echo 'module load java/jdk-13.33 samtools/1.10' >> pilon_polish.pbs
    echo "" >> pilon_polish.pbs

    echo "RUNNUMBER=1" >> pilon_polish.pbs
    echo "LAST=assembly.fasta" >> pilon_polish.pbs
    echo "CURRENT=1/pilon.fasta" >> pilon_polish.pbs
    echo "READS=${readsFile}" >> pilon_polish.pbs
    echo "SAVE_DIR=${fna}_pilon_chloroplast" >> pilon_polish.pbs
    echo "" >> pilon_polish.pbs

    ## copy to working dir
    echo "mkdir -p /scratch/\${PROJECT}/\${USER}/\${SAVE_DIR}" >> pilon_polish.pbs
    echo "cp unicycler-long/assembly.fasta /scratch/\${PROJECT}/\${USER}/\${SAVE_DIR}" >> pilon_polish.pbs
    echo "cp ${reads} \${PBS_JOBFS}" >> pilon_polish.pbs
    echo "gunzip \${PBS_JOBFS}/\${READS}.gz" >> pilon_polish.pbs
    echo "" >> pilon_polish.pbs

    ## index assembly & map short reads with bwa mem
    echo "/g/data/xe2/scott/gadi_modules/bwa/bwa index /scratch/\${PROJECT}/\${USER}/\${SAVE_DIR}/\${LAST}" >> pilon_polish.pbs
    echo "/g/data/xe2/scott/gadi_modules/bwa/bwa mem -t \${PBS_NCPUS} /scratch/\${PROJECT}/\${USER}/\${SAVE_DIR}/\${LAST} \${PBS_JOBFS}/\${READS} | \\" >> pilon_polish.pbs
    echo "    samtools sort -m 41G -T \${PBS_JOBFS}/tmp -@ \${PBS_NCPUS} > \${PBS_JOBFS}/sorted_mapped_reads.bam" >> pilon_polish.pbs
    echo "samtools index -@ \${PBS_NCPUS} \${PBS_JOBFS}/sorted_mapped_reads.bam" >> pilon_polish.pbs
    echo "" >> pilon_polish.pbs

    ## run pilon
    echo "java -Xmx995G -jar /g/data/xe2/scott/gadi_modules/pilon-1.23.jar \\" >> pilon_polish.pbs
    echo "    --genome /scratch/\${PROJECT}/\${USER}/\${SAVE_DIR}/\${LAST} \\" >> pilon_polish.pbs
    echo "    --bam \${PBS_JOBFS}/sorted_mapped_reads.bam \\" >> pilon_polish.pbs
    echo "    --outdir /scratch/\${PROJECT}/\${USER}/\${SAVE_DIR}/\$RUNNUMBER \\" >> pilon_polish.pbs
    echo "    --changes \\" >> pilon_polish.pbs
    echo "    --threads \${PBS_NCPUS} \\" >> pilon_polish.pbs
    echo "    --fix all \\" >> pilon_polish.pbs
    echo "    --tracks " >> pilon_polish.pbs
    echo "" >> pilon_polish.pbs

    echo "for i in {1..4}" >> pilon_polish.pbs
    echo "do" >> pilon_polish.pbs

    echo "RUNNUMBER=\$((\$RUNNUMBER + 1))" >> pilon_polish.pbs
    echo "LAST=\$CURRENT" >> pilon_polish.pbs
    echo "CURRENT=\$RUNNUMBER'/pilon.fasta'" >> pilon_polish.pbs
    echo "" >> pilon_polish.pbs

   ## index assembly & map short reads with bwa mem
    echo "/g/data/xe2/scott/gadi_modules/bwa/bwa index /scratch/\${PROJECT}/\${USER}/\${SAVE_DIR}/\${LAST}" >> pilon_polish.pbs
    echo "/g/data/xe2/scott/gadi_modules/bwa/bwa mem -t \${PBS_NCPUS} /scratch/\${PROJECT}/\${USER}/\${SAVE_DIR}/\${LAST} \${PBS_JOBFS}/\${READS} | \\" >> pilon_polish.pbs
    echo "    samtools sort -m 41G -T \${PBS_JOBFS}/tmp -@ \${PBS_NCPUS} > \${PBS_JOBFS}/sorted_mapped_reads.bam" >> pilon_polish.pbs
    echo "samtools index -@ \${PBS_NCPUS} \${PBS_JOBFS}/sorted_mapped_reads.bam" >> pilon_polish.pbs
    echo "" >> pilon_polish.pbs

    ## run pilon
    echo "java -Xmx995G -jar /g/data/xe2/scott/gadi_modules/pilon-1.23.jar \\" >> pilon_polish.pbs
    echo "    --genome /scratch/\${PROJECT}/\${USER}/\${SAVE_DIR}/\${LAST} \\" >> pilon_polish.pbs
    echo "    --bam \${PBS_JOBFS}/sorted_mapped_reads.bam \\" >> pilon_polish.pbs
    echo "    --outdir /scratch/\${PROJECT}/\${USER}/\${SAVE_DIR}/\$RUNNUMBER \\" >> pilon_polish.pbs
    echo "    --changes \\" >> pilon_polish.pbs
    echo "    --threads \${PBS_NCPUS} \\" >> pilon_polish.pbs
    echo "    --fix all \\" >> pilon_polish.pbs
    echo "    --tracks " >> pilon_polish.pbs
    echo "" >> pilon_polish.pbs
    echo "done" >> pilon_polish.pbs

    if [[ "$readsFile" != "XXXXX" ]]; then
        qsub pilon_polish.pbs
    fi
    cd ../
done
