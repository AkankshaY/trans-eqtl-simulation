#!/bin/bash

if [ "$PS1" ]; then echo -e "This script cannot be sourced. Use \"${BASH_SOURCE[0]}\" instead." ; return ; fi

CONFIGFILE=$1
if [ -z ${CONFIGFILE} ] || [ ! -f ${CONFIGFILE} ]; then
    echo "Fatal! No configuration file found.";
    echo "Use this script as: ${BASH_SOURCE[0]} CONFIGFILE";
    exit 1;
fi
source ${CONFIGFILE}
source PATHS
source EXTERNAL
source ${UTILSDIR}/submit_job
source ${UTILSDIR}/add_deps
source ${UTILSDIR}/read_simparams

echo "Number of datasets: ${#SIMPARAMS[@]}"

# Run simulation for each set of parameters
for PARAMSTR in ${SIMPARAMS[@]}; do
    OUTDIR="${OUTDIRUP}/${PARAMSTR}"

    ENDSIM=$(( STARTSIM + NSIM ))
    for (( SIM=$STARTSIM; SIM<$ENDSIM; SIM++ )); do

        SIMINDEX=`echo $SIM | awk '{printf "%03d", $1}'`
        SIMDIR="${OUTDIR}/$PARAMSTR/sim${SIMINDEX}"
        RANDSTRING=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 4 | head -n 1`
        RUNJPA=false    # used for submitting jpa-only jobs
        SHUFFLE=false   # used for controlling shuffling
        JOBDEPS="None"  # used for controlling job dependencies

        JOBSUBDIR_SIM="${JOBSUBDIR}/${PARAMSTR}/sim${SIMINDEX}"
        OUTDIR_SIM="${OUTDIRUP}/${PARAMSTR}/sim${SIMINDEX}"
        SIMGTFILE="${OUTDIR_SIM}/input/genotype.vcf.gz"
        SIMGXFILE="${OUTDIR_SIM}/input/expression.txt"

        if [ "${bGenerateData}" = "true" ]; then source ${UTILSDIR}/generate_data; fi
        #if [ "${bMatrixEqtl}" = "true" ];  then source ${UTILSDIR}/matrix_eqtl; fi
        #if [ "${bMEqtlRandom}" = "true" ]; then SHUFFLE=true; source ${UTILSDIR}/matrix_eqtl; fi
        #if [ "${bTejaas}" = "true" ];      then source ${UTILSDIR}/tejaas; fi
        #if [ "${bTjsRandom}" = "true" ];   then SHUFFLE=true; source ${UTILSDIR}/tejaas; fi
        #if [ "${bTejaasJPA}" = "true" ];   then RUNJPA=true; source ${UTILSDIR}/tejaas; fi
        #if [ "${bJPARandom}" = "true" ];   then SHUFFLE=true; RUNJPA=true; source ${UTILSDIR}/tejaas; fi

    done

    #if [ "${bValidationPlot}" = "true" ]; then source ${UTILSDIR}/validation_plot; fi

done