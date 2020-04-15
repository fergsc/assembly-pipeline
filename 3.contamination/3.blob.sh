#!bin/bash

if [ -f blobs.lst ]; then
    echo "blobs.lst exist - run the following commands"
    echo ""
    echo ""
else 
    echo "blobs.lst does not exist and will be created. You should edit this, then rerun."
    find . -name 'blast.out' | grep '2.blast_contamination' > blobs.lst
        exit 0
fi

for blob in `cat blobs.lst`
do
    species=`echo $blob | cut -f2 -d'/'`
    genome=`find $species -name '*.contigs.fasta'`
    dir=`echo $blob | awk '{split($0,a,"/"); print "/g/data/xe2/scott/assembly/" a[1] "/" a[2] "/" a[3]}'`
    echo "cd $dir"
    echo "/g/data/xe2/scott/gadi_modules/blobtools/blobtools create -i /g/data/xe2/scott/assembly/${genome} -b sorted_mapped_reads.bam -t blast.out -o contamination"
    echo "/g/data/xe2/scott/gadi_modules/blobtools/blobtools plot -i contamination.blobDB.json -o blobP"
    echo "/g/data/xe2/scott/gadi_modules/blobtools/blobtools view -i contamination.blobDB.json -o blobV"
    echo ""
done
