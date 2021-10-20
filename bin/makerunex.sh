#!/bin/bash

# Extract EXP (if not set) from the expected path to this executable
# Expected path is $HOME/extractGribConfig/<EXP>/bin/
EXPATH=$(dirname $(dirname $0))
MYEXP=$(basename ${EXPATH})
EXP=${EXP-$MYEXP}

# Set USERAREA from EXPATH
USERAREA="-a ${EXPATH}/share/griblists"

# Check for extractGrib scripts
which extractGrib 2> /dev/null
if [ $? -ne 0 ] ; then
 echo "Error: extractGrib not found, please 'module load extractGrib' first" 
 exit 1
fi

# Source the config_exp.h
HM_LIB=$SCRATCH/hm_home/${EXP}/lib
source ${HM_LIB}/ecf/config_exp.h || exit 1

# Check for sufficient data
echo
echo "EXP: ${EXP}    DOMAIN: ${DOMAIN}    DTG: ${DTG}"
if [ -z "${DTG}" ]; then
    echo "Error, please set <DTG> before running this script"
    exit 1
fi

# create YYYY MM DD HH from DTG
YYYY=$(echo $DTG | cut -c1-4)
MM=$(echo $DTG | cut -c5-6)
DD=$(echo $DTG | cut -c7-8)
HH=$(echo $DTG | cut -c9-10)

# Forecast path
FCSTPATH=$SCRATCH/hm_home/${EXP}/archive/${YYYY}/${MM}/${DD}/${HH}
if [ ! -d ${FCSTPATH} ]; then
    echo "Error, $FCSTPATH does not exist"
    exit 1
fi

# Pad ENSMBR and STEP (if set) with leading zeros to 3 digits
if [ ! -z "${ENSMBR}" ]; then
    ENSMBR=$(echo 00${ENSMBR} | sed -e 's/.*\([0-9][0-9][0-9]\)$/\1/')
fi
if [ ! -z "${STEP}" ]; then
    STEP=$(echo 00${STEP} | sed -e 's/.*\([0-9][0-9][0-9]\)$/\1/')
fi

# Workpath
WORKPATH=${WORKPATH-$(pwd)}

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
export FCSTPATH=${FCSTPATH}
export ENSMBR=${ENSMBR-000}
export WORKPATH=${WORKPATH}
export STEP=${STEP-000}
EXTGRIBARGS=${EXTGRIBARGS}

cd \$WORKPATH

export MPPGL="mpiexec -n \$EC_total_tasks"
/usr/bin/time -v $(which extractGrib) ${USERAREA} \$EXTGRIBARGS 
RUNEX

# Make the runex.sh executable
chmod +x runex.sh

cat << OUTT

runex.sh script now created.

Run this script thus:

	qsub runex.sh

and await output.  You can see its queue state:

	qstat -u $USER

Forecast Source: $FCSTPATH
Output         : $WORKPATH

Output logfile in $(echo $WORKPATH | sed -e "s@$(pwd)@.@")/log/extractGrib_control_${DTG}_${STEP}.log
and in $(echo $WORKPATH | sed -e "s@$(pwd)@.@")/extractGribtest.o<NNNNN>
and in $(echo $WORKPATH | sed -e "s@$(pwd)@.@")/extractGribtest.e<NNNNN> where NNNNN is the job ID.

OUTT
