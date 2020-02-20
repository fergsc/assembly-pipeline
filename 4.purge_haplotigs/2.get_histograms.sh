#!/bin/bash

	for hist in `find . -name '*bam.histogram.png'`
do
	name=`echo $hist | cut -d / -f2`
	mkdir -p purge_histograms
	echo "cp $hist purge_histograms/$name.histogram.png"
done
