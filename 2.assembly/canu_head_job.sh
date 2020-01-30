set -euo pipefail # safe mode
set -x # logging

NAME=xxx
SAVE_DIR=xxx
READS=xxx # can be gz
GENOME_SIZE=xxx # use m,g for mega/giga BP

GRID_OPTIONS="-P ${PROJECT} -q normal -l jobfs=400GB -l software=canu -l wd -l walltime=20:00:00 -l storage=scratch/${PROJECT}+gdata/${PROJECT}"


/path_to_canu/Linux-amd64_intel-cascade/bin/canu \
	-p ${NAME} \
	-d ${SAVE_DIR}  \
	-nanopore-raw ${READS} \
	genomeSize=${GENOME_SIZE} \
	maxThreads=512 \
	maxMemory=63 \
	gridOptions="$GRID_OPTIONS" \
	useGrid=remote \
	gridEngineResourceOption="-l ncpus=THREADS -l mem=MEMORY" \
	executiveMemory=2 \
	executiveThreads=1 \
	java=/apps/java/jdk-13.33/bin/java \
	stageDirectory=\${PBS_JOBFS} \
	corOutCoverage=200 "batOptions=-dg 3 -db 3 -dr 1 -ca 500 -cp 50" \
	correctedErrorRate=0.154 \
	corMaxEvidenceErate=0.15 \
	-fast \
	gridEngineArrayMaxJobs=2000

