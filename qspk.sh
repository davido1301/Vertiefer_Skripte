#!/bin/bash
#$ -l qu=gtx
#$ -cwd
#$ -o train.out
#$ -e train.err
#$ -q gtx01a,gtx01b,gtx01c,gtx01d,gtx02a,gtx02b,gtx02c,gtx02d,gtx03a,gtx03b,gtx03c,gtx03d,gtx05a,gtx05b,gtx05c,gtx05d,gtx06a,gtx06b,gtx06c,gtx06d,gtx09a,gtx09b,gtx09c,gtx09d,gtx10a,gtx10b,gtx10c,gtx10d

pythonfile=$1
pythonfile=${pythonfile#"/srv/nfs"}
shift
other_commands=$@

# Which GPU?
gpu_id=$( echo $QUEUE | awk '/a/ {print 0} /b/ {print 1}  /c/ {print 2}  /d/ {print 3}')

# How many cores are there?
case $HOSTNAME in
    gtx0[1-6]*)
    cores=10;
    ;;
    gtx0[7-8]*)
    cores=12;
    ;;
    gtx09*)
    cores=16;
    ;;
    gtx10*)
    cores=16;
    ;;
    *)
    echo "Error: Unknown compute node $HOSTNAME"
    echo "       This script only works for gtx01 thru 10!"
    echo
    exit -1
    ;;
esac

# Echo important information into file
echo "# Hostname: " `hostname`
echo "# Job ID: " $JOB_ID
echo "# gpuid: " $gpu_id

# In case of external API usage I saved some API-keys here
if [ -f ~/.api_keys ]; then
    . ~/.api_keys
fi

# For WandB:
export WANDB_MODE=offline # no internet connection during calculation on nodes

# For data readin in kgcnn
export BABEL_DATADIR="/usr/local/run/openbabel-2.4.1"

export PATH="/home/user7/miniconda3/bin:$PATH"
source /home/user7/miniconda3/etc/profile.d/conda.sh
conda activate schnetpack

# set OpenMP parallel threads variable:
export OMP_NUM_THREADS=$cores

# OpenMP needs this: set stack size to unlimited
ulimit -s unlimited
# Start time of calculation
start=$( date "+%s" )

echo "$other_commands"
time $pythonfile $other_commands

# End time of calculation
end=$( date "+%s" )
# Now we calculate the time taken by the calculation
duration=$(( end - start ))
# Now we do Wibbly Wobbly Timey Wimey... Stuff
DAYS=$(( duration / 86400 ))
HOURS=$(( (duration % 86400) / 3600 ))
MINS=$(( ((duration % 86400) % 3600) / 60 ))
SECS=$(( ((duration % 86400) % 3600) % 60 ))
echo "Time taken: $DAYS days, $HOURS hours, $MINS minutes and $SECS seconds."
