#!/bin/bash

# Extract EXP (if not set) from the expected path to this executable
# Expected path is $HOME/extractGribConfig/<EXP>/bin/
EXP=${EXP-$(basename $(dirname $(dirname $0)))}

# Source the config_exp.h
HM_LIB=$SCRATCH/hm_home/${EXP}/lib
source ${HM_LIB}/ecf/config_exp.h || exit 1

# Check for sufficient data
echo
echo "<EXP> ${EXP}, <DOMAIN> ${DOMAIN} <DTG> ${DTG}"
if [ -z "${DTG}" ]; then
    echo "Error, please set <DTG> before running this script"
    exit 1
fi

# Build the runex.sh file
cat > runex.sh << RUNEX
#PBS -N extractGribtest
#PBS -q nf
#PBS -l EC_total_tasks=1
#PBS -l EC_threads_per_task=12
#PBS -l EC_memory_per_task=70000MB

export OMP_NUM_THREADS=\$EC_threads_per_task
 
## Load the cray-snplauncher module to add the mpiexec command to \$PATH
#module load cray-snplauncher

# Set up the extractGrib module
module use \$HOME/privatemodules
module load extractGrib
which gl

export EXP=${EXP}
export DOMAIN=${DOMAIN}
export DTG=${DTG}
export YYYY=$(echo $DTG | cut -c1-4)
export   MM=$(echo $DTG | cut -c5-6)
export   DD=$(echo $DTG | cut -c7-8)
export   HH=$(echo $DTG | cut -c9-10)
export FCSTPATH=\$SCRATCH/hm_home/${EXP}/archive/\${YYYY}/\${MM}/\${DD}/\${HH}
export ENSMBR=${ENSMBR-000}
export WORKPATH=\$SCRATCH/hm_home/${EXP}/archive/extractGribFiles
export STEP=${STEP-000}
EXTGRIBARGS=\${EXTGRIBARGS}

cd \$WORKPATH

export MPPGL="mpiexec -n \$EC_total_tasks"
/usr/bin/time -v $(which extractGrib) \$EXTGRIBARGS 
RUNEX

# Make the runex.sh executable
chmod +x runex.sh

cat << OUTT

runex.sh script now created.

Run this script thus:

	qsub runex.sh

and await output.  You can see its queue state:

	qstat -u $USER

Output logfile in $WORKPATH/log/extractGrib_control_${DTG}_${STEP}.log
and in $WORKPATH/extractGribtest.o<NNNNN>
and in $WORKPATH/extractGribtest.e<NNNNN> where NNNNN is the job ID.

OUTT
