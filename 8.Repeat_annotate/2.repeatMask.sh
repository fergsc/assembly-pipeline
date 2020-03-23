if [ -f maskGenomes.lst ]; then
    echo "maskGenomes.lst exist - proceed"
else
    echo "maskGenomes.lst does not exist and will be created. You should edit this, then rerun."
    touch repeat.lst

    ls -1 /g/data/xe2/scott/assembly/genomes/RaGOO/*.fasta > maskGenomes.lst
    exit 0
fi

pwd=`pwd`

mkdir -p /g/data/xe2/scott/assembly/genomes/RaGOO-masked/
cd /g/data/xe2/scott/assembly/genomes/RaGOO-masked/

for fna in `cat $pwd/maskGenomes.lst`
do
   # get genome name -> find repeat library
   # run job

   fnaFile=$(basename $fna)
   species="${fnaFile%.*}"
   echo $species

   library=`find /g/data/xe2/scott/assembly/repeat-libraries -name "*$species*fa"`
   libraryFile=$(basename $library)

   if [[ -z $library ]]
   then
      echo "$species: Library not found"

   else
      # we have a repeat library!!

      echo "#!/bin/bash" > ${species}RepeatMask.pbs
      echo "#PBS -P xe2" >> ${species}RepeatMask.pbs
      echo "#PBS -q normal" >> ${species}RepeatMask.pbs
      echo "#PBS -l walltime=20:00:00" >> ${species}RepeatMask.pbs
      echo "#PBS -l mem=24G" >> ${species}RepeatMask.pbs
      echo "#PBS -l jobfs=100GB" >> ${species}RepeatMask.pbs
      echo "#PBS -l ncpus=6" >> ${species}RepeatMask.pbs
      echo "#PBS -l storage=gdata/xe2" >> ${species}RepeatMask.pbs
      echo "#PBS -l wd" >> ${species}RepeatMask.pbs
      echo "" >> ${species}RepeatMask.pbs
      echo "set -euo pipefail # safe mode" >> ${species}RepeatMask.pbs
      echo "set -x # logging" >> ${species}RepeatMask.pbs
      echo "set +u" >> ${species}RepeatMask.pbs
      echo 'eval "$(/g/data/xe2/gadi/conda/bin/conda shell.zsh hook)"' >> ${species}RepeatMask.pbs
      echo "conda activate rm_test" >> ${species}RepeatMask.pbs
      echo "set -u" >> ${species}RepeatMask.pbs
      echo "" >> ${species}RepeatMask.pbs
      echo "cp $library \${PBS_JOBFS}" >> ${species}RepeatMask.pbs
      echo "cp $fna \${PBS_JOBFS}" >> ${species}RepeatMask.pbs
      echo "" >> ${species}RepeatMask.pbs
      echo "RepeatMasker -pa ${PBS_NCPUS} -s -lib \${PBS_JOBFS}/$libraryFile \\" >> ${species}RepeatMask.pbs
      echo "   -dir $species -e ncbi \\" >> ${species}RepeatMask.pbs
      echo "   \${PBS_JOBFS}/$fnaFile" >> ${species}RepeatMask.pbs
    fi
    
    qsub ${species}RepeatMask.pbs
done

cd $pwd
