#!/bin/bash

# Check for extractGrib scripts
module load use.own
module load extractGrib
module list
which extractGrib 2> /dev/null
if [ $? -ne 0 ]; then
    echo "Error: extractGrib not found, please 'module load extractGrib' first" 
    exit 1
fi

echo "Generating namelist fragments from paramlists..."
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
