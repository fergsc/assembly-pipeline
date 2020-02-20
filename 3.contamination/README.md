# Contamination filtering.
I use blastn and the ncbi nt database to identify the taxonomic origin of all assembled contigs.
blobtools is then used to interperet the blast output into a useable format.
blobtools also makes use of read alignemnt inforamtion for its analysis. As such reads are aligned with minimap.
Minimap is run in a seperate script as it can make use of multiple cores. blast and blobtools do not.
Finally seqtk and grep are used to filter out any contaminat contigs from our assembly. 

Download blast nt database:  `update_blastdb.pl --decompress nt --blastdb_version 5`

Alternatively Diamond could be used and potentially speed up runtime and allowing multithread abillity. But I found daimond output to be classified as "undef". I didn't spend the time to trouble shoot this, just used blastn.
