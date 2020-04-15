#!/bin/bash

#
# run this to filter contamination from assemblies.
# Results will be printed to terminal. Select, copy and paste to run.
#


#!/bin/bash

#
# run this to filter contamination from assemblies.
# Results will be printed to terminal. Select, copy and paste to run.
#


if [ -f filter.lst ]; then
    echo "filter.lst exist - proceeding..."
else
    echo "filter.lst does not exist and will be created. You should edit this, then rerun."
    find . -name '*.blobDB.table.txt' > filter.lst
        exit 0
fi


for blob in `cat filter.lst`
do
   species=`echo $blob | cut -f2 -d'/'`
   assembly=`find $species -name '*.contigs.fasta'`
   dir=$(dirname "$blob")

   echo "grep -v '^#' $blob | grep -vE 'Bacteroidetes|Ascomycota|Proteobacteria|Arthropoda' | awk '{print \$1}' > $dir/keep_contigs.lst"
   echo "grep -v '^#' $blob | grep -E 'Bacteroidetes|Ascomycota|Proteobacteria|Arthropoda' | awk '{print \$1}' > $dir/contaminant_contigs.lst"
   echo "seqtk subseq $assembly $dir/keep_contigs.lst > $dir/keep.fasta"
   echo "seqtk subseq $assembly $dir/contaminant_contigs.lst > $dir/contamination.fasta"
   echo ""
done
