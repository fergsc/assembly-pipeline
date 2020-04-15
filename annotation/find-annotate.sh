if [ -f assembly.lst ]; then
   echo "assembly.lst exist - proceed"
else 
   echo "assembly.lst does not exist and will be created. You should edit this, then rerun."
   ls -1 /g/data/xe2/scott/assembly/genomes/RaGOO-soft/*.fasta > assembly.lst
   exit 0
fi

pwd=`pwd`
for fna in `cat assembly.lst`
do
   # get species name
   fnaFile=$(basename $fna)
   species=${fnaFile%.*}
   echo $species

   echo "#!/bin/bash" >> ${species}-braker.pbs
   echo "#PBS -P xe2" >> ${species}-braker.pbs
   echo "#PBS -q normal" >> ${species}-braker.pbs
   echo "#PBS -l walltime=30:00:00" >> ${species}-braker.pbs
   echo "#PBS -l mem=24G" >> ${species}-braker.pbs
   echo "#PBS -l jobfs=400GB" >> ${species}-braker.pbs
   echo "#PBS -l ncpus=6" >> ${species}-braker.pbs
   echo "#PBS -l storage=scratch/xe2+gdata/xe2" >> ${species}-braker.pbs
   echo "## The job will be executed from current working directory instead of home." >> ${species}-braker.pbs
   echo "#PBS -l wd" >> ${species}-braker.pbs
   echo "" >> ${species}-braker.pbs
   echo "set -euo pipefail # safe mode" >> ${species}-braker.pbs
   echo "set -x # logging" >> ${species}-braker.pbs
   echo "" >> ${species}-braker.pbs
   echo "# /scratch/${PROJECT}/${USER}" >> ${species}-braker.pbs
   echo "# \${PBS_NCPUS}  \${PBS_JOBFS}" >> ${species}-braker.pbs
   echo "" >> ${species}-braker.pbs
   echo "##useconda" >> ${species}-braker.pbs
   echo "set +u" >> ${species}-braker.pbs
   echo 'eval "$(/g/data/xe2/gadi/conda/bin/conda shell.zsh hook)"' >> ${species}-braker.pbs
   echo "conda activate BRAKER2b" >> ${species}-braker.pbs
   echo "set -u" >> ${species}-braker.pbs
   echo "" >> ${species}-braker.pbs
   echo "cp $fna \${PBS_JOBFS}" >> ${species}-braker.pbs
   echo "cp /g/data/xe2/scott/assembly/annotate/faa/A_thaliana-Myrtaceae.faa \${PBS_JOBFS}" >> ${species}-braker.pbs
   echo "" >> ${species}-braker.pbs
   echo "braker.pl --genome=\${PBS_JOBFS}/${fnaFile} \\" >> ${species}-braker.pbs
   echo "   --prot_seq=\${PBS_JOBFS}/A_thaliana-Myrtaceae.faa \\" >> ${species}-braker.pbs
   echo "   --prg=gth \\" >> ${species}-braker.pbs
   echo "   --gth2traingenes \\" >> ${species}-braker.pbs
   echo "   --softmasking \\" >> ${species}-braker.pbs
   echo "   --workingdir=/scratch/xe2/sf3809/${species}-annotate \\" >> ${species}-braker.pbs
   echo "   --nocleanup \\" >> ${species}-braker.pbs
   echo "   --cores=\${PBS_NCPUS} \\" >> ${species}-braker.pbs
   echo "   --species=${species} \\" >> ${species}-braker.pbs
   echo "   --gff3 \\" >> ${species}-braker.pbs
   echo "   --useexisting \\" >> ${species}-braker.pbs
   echo "   --BAMTOOLS_PATH="/g/data/xe2/gadi/conda/envs/BRAKER2b/bin" \\" >> ${species}-braker.pbs
   echo "   --SAMTOOLS_PATH="/g/data/xe2/gadi/conda/envs/BRAKER2b/bin" \\" >> ${species}-braker.pbs
   echo "   --ALIGNMENT_TOOL_PATH="/g/data/xe2/gadi/conda/envs/BRAKER2b/bin" \\" >> ${species}-braker.pbs
   echo "   --DIAMOND_PATH="/g/data/xe2/gadi/conda/envs/BRAKER2b/bin" \\" >> ${species}-braker.pbs
   echo "   --BLAST_PATH="/g/data/xe2/gadi/conda/envs/BRAKER2b/bin" \\" >> ${species}-braker.pbs
   echo "   --MAKEHUB_PATH="/g/data/xe2/gadi/conda/envs/BRAKER2b/bin" \\" >> ${species}-braker.pbs
   echo "   --AUGUSTUS_CONFIG_PATH="/g/data/xe2/gadi/conda/envs/BRAKER2b/config/" \\" >> ${species}-braker.pbs
   echo "   --AUGUSTUS_BIN_PATH="/g/data/xe2/gadi/conda/envs/BRAKER2b/bin" \\" >> ${species}-braker.pbs
   echo "   --AUGUSTUS_SCRIPTS_PATH="/g/data/xe2/gadi/conda/envs/BRAKER2b/bin" \\" >> ${species}-braker.pbs
   echo "   --GENEMARK_PATH="/g/data/xe2/scott/gadi_modules/gm_et_linux_64" \\" >> ${species}-braker.pbs
   echo "   --CDBTOOLS_PATH="/g/data/xe2/scott/gadi_modules/cdbfasta" \\" >> ${species}-braker.pbs
   echo "   --PYTHON3_PATH="/g/data/xe2/gadi/conda/envs/BRAKER2b/bin"" >> ${species}-braker.pbs

   qsub ${species}-braker.pbs
done
