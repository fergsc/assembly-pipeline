# genome file
This is often used to examine reads with in a fastq or conting sizes & length in an assembly.

bioawk -c fastx '{print $name, length($seq)}' xxx.fasta/q > xxx.genome