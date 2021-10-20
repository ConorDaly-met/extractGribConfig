#!/bin/bash

# Check for extractGrib scripts
which extractGrib 2> /dev/null
[ $? -eq 0 ] || echo "Error: extractGrib not found, please 'module load extractGrib' first" && exit 1

bindir=$(dirname $0)
wrkdir=${bindir}/../

cd $wrkdir
pwd
for D in $(find share/paramlists/ -type d); do
	DD=$(echo $D | sed -e 's/paramlists/namelist_inc/')
	for F in $(find $D -maxdepth 1 -type f); do
		do_paramset.sh -b -o $DD $F 
	done
done
