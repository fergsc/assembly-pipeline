#!/bin/bash

#number of pairwise comparisons = k(k-1)/2
numFna=`ls -1 genomes/*.fasta | wc -l`
number=`echo "${numFna}*(${numFna}-1)/2" | bc`
echo "The number of comparisions = $number"

for ref in genomes/*.fasta
do
   tmp=$(basename $ref)
   speciesRef=${tmp%.*}

   for query in genomes/*.fasta
   do
      tmp=$(basename $query)
      speciesQry=${tmp%.*}
      if [ $speciesRef == $speciesQry ]
      then
        continue
      fi

      script="${speciesRef}_${speciesQry}.pbs"
      checkScript="${speciesQry}_${speciesRef}.pbs"

      if [[ -f "$checkScript" || -f "$script" ]]
      then
         continue
      fi

      echo "#!/bin/bash" > ${script}
      echo "#PBS -P xe2" >> ${script}
      echo "#PBS -q normal" >> ${script}
      echo "#PBS -l walltime=48:00:00" >> ${script}
      echo "#PBS -l mem=32G" >> ${script}
      echo "#PBS -l jobfs=100GB" >> ${script}
      echo "#PBS -l ncpus=2" >> ${script}
      echo "#PBS -l storage=gdata/xe2" >> ${script}
      echo "#PBS -l wd" >> ${script}
      echo "#PBS -j oe" >> ${script}
      echo "" >> ${script}
      echo "set -euo pipefail # safe mode" >> ${script}
      echo "set -x # logging" >> ${script}
      echo "set +u" >> ${script}
      echo 'eval "$(/g/data/xe2/gadi/conda/bin/conda shell.zsh hook)"' >> ${script}
      echo "conda activate SyRI" >> ${script}
      echo "set -u" >> ${script}
      echo "" >> ${script}
      echo "pwd=`pwd`" >> ${script}
      echo "mkdir ${speciesRef}_${speciesQry}" >> ${script}
      echo "cp $ref \${PBS_JOBFS}" >> ${script}
      echo "cp $query \${PBS_JOBFS}" >> ${script}
      echo "cd \${PBS_JOBFS}" >> ${script}
      echo "" >> ${script}

      echo "/g/data/xe2/scott/gadi_modules/MUMmer3.23/nucmer --maxmatch -l 40 -b 500 -c 200 -p ${speciesRef}_${speciesQry} ${speciesRef}.fasta ${speciesQry}.fasta" >> ${script}
      echo "cp ${speciesRef}_${speciesQry}* \${pwd}/${speciesRef}_${speciesQry}" >> ${script}
      echo "cd \${pwd}" >> ${script}
      echo "qsub 2_${script}" >> ${script}

# part 2 - filter nucmer results
      echo "#!/bin/bash" > 2_${script}
      echo "#PBS -P xe2" >> 2_${script}
      echo "#PBS -q normal" >> 2_${script}
      echo "#PBS -l walltime=48:00:00" >> 2_${script}
      echo "#PBS -l mem=8G" >> 2_${script}
      echo "#PBS -l jobfs=100GB" >> 2_${script}
      echo "#PBS -l ncpus=1" >> 2_${script}
      echo "#PBS -l storage=gdata/xe2" >> 2_${script}
      echo "#PBS -l wd" >> 2_${script}
      echo "#PBS -j oe" >> 2_${script}
      echo "" >> 2_${script}
      echo "set -euo pipefail # safe mode" >> 2_${script}
      echo "set -x # logging" >> 2_${script}
      echo "set +u" >> 2_${script}
      echo 'eval "$(/g/data/xe2/gadi/conda/bin/conda shell.zsh hook)"' >> 2_${script}
      echo "conda activate SyRI" >> 2_${script}
      echo "set -u" >> 2_${script}
      echo "" >> 2_${script}
      echo "pwd=`pwd`" >> 2_${script}
      echo "cp ${speciesRef}_${speciesQry}/*delta \${PBS_JOBFS}" >> 2_${script}
      echo "cd \${PBS_JOBFS}" >> 2_${script}
      echo "" >> 2_${script}
      echo "/g/data/xe2/scott/gadi_modules/MUMmer3.23/delta-filter -m -i 90 -l 100 ${speciesRef}_${speciesQry}.delta > ${speciesRef}_${speciesQry}_m_i90_l100.delta" >> 2_${script}
      echo "cp ${speciesRef}_${speciesQry}_m_i90_l100.delta \${pwd}/${speciesRef}_${speciesQry}" >> 2_${script}
      echo "/g/data/xe2/scott/gadi_modules/MUMmer3.23/show-coords -THrd ${speciesRef}_${speciesQry}_m_i90_l100.delta > ${speciesRef}_${speciesQry}_m_i90_l100.coords" >> 2_${script}
      echo "cp ${speciesRef}_${speciesQry}_m_i90_l100.coords \${pwd}/${speciesRef}_${speciesQry}" >> 2_${script}
      echo "cd \${pwd}" >> 2_${script}
      echo "qsub 3_${script}" >> 2_${script}

#part 3 - syri
      echo "#!/bin/bash" > 3_${script}
      echo "#PBS -P xe2" >> 3_${script}
      echo "#PBS -q normal" >> 3_${script}
      echo "#PBS -l walltime=48:00:00" >> 3_${script}
      echo "#PBS -l mem=24G" >> 3_${script}
      echo "#PBS -l jobfs=100GB" >> 3_${script}
      echo "#PBS -l ncpus=4" >> 3_${script}
      echo "#PBS -l storage=gdata/xe2" >> 3_${script}
      echo "#PBS -l wd" >> 3_${script}
      echo "#PBS -j oe" >> 3_${script}
      echo "" >> 3_${script}
      echo "set -euo pipefail # safe mode" >> 3_${script}
      echo "set -x # logging" >> 3_${script}
      echo "set +u" >> 3_${script}
      echo 'eval "$(/g/data/xe2/gadi/conda/bin/conda shell.zsh hook)"' >> 3_${script}
      echo "conda activate SyRI" >> 3_${script}
      echo "set -u" >> 3_${script}
      echo "" >> 3_${script}

#      echo "pwd=`pwd`" >> 3_${script}
#      echo "cp $ref \${PBS_JOBFS}" >> 3_${script}
#      echo "cp $query \${PBS_JOBFS}" >> 3_${script}
#      echo "cp ${speciesRef}_${speciesQry}/${speciesRef}_${speciesQry}_m_i90_l100.* \${PBS_JOBFS}" >> 3_${script}
#      echo "cd \${PBS_JOBFS}" >> 3_${script}

      echo "pwd=`pwd`" >> 3_${script}
      echo "cp $ref \${PBS_JOBFS}" >> 3_${script}
      echo "cp $query \${PBS_JOBFS}" >> 3_${script}
      echo "cp ${speciesRef}_${speciesQry}/${speciesRef}_${speciesQry}_m_i90_l100.coords \${PBS_JOBFS}" >> 3_${script}
      echo "echo \"\${PBS_JOBFS}/${speciesRef}.fasta \${PBS_JOBFS}/${speciesQry}.fasta\" > \${PBS_JOBFS}/${speciesRef}_${speciesQry}_m_i90_l100.delta" >> 3_${script}
      echo "sed '1d' ${speciesRef}_${speciesQry}/${speciesRef}_${speciesQry}_m_i90_l100.delta >> \${PBS_JOBFS}/${speciesRef}_${speciesQry}_m_i90_l100.delta" >> 3_${script}
      echo "cd \${PBS_JOBFS}" >> 3_${script}

      echo "" >> 3_${script}
      echo "python /g/data/xe2/scott/gadi_modules/syri/syri/bin/syri -c ${speciesRef}_${speciesQry}_m_i90_l100.coords \\" >> 3_${script}
      echo "   -r \${PBS_JOBFS}/${speciesRef}.fasta \\" >> 3_${script}
      echo "   -q \${PBS_JOBFS}/${speciesQry}.fasta \\" >> 3_${script}
      echo "   -d ${speciesRef}_${speciesQry}_m_i90_l100.delta \\" >> 3_${script}
      echo "   --nc 4 \\" >> 3_${script}
      echo "   -s /g/data/xe2/scott/gadi_modules/MUMmer3.23/show-snps" >> 3_${script}
      echo "" >> 3_${script}
      echo "cp syri* \${pwd}/${speciesRef}_${speciesQry}" >> 3_${script}
      echo "" >> 3_${script}
      echo "echo ${script} >> \${pwd}/mummerSuccess.txt" >> 3_${script}

      #qsub ${script}
   done
done
