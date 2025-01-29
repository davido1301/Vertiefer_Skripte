# Submit the python script to the queue and gives it the name of the current folder in the queue
# Use the -s flag to keep this process running until it finishes and sync training data to wandb

python_script="spktrain"
echo "Submitting $(which $python_script) to queue"

queue_script="/home/user7/sneff/scripts/qspk.sh"

sync=true

if [ -f train.err ]
then rm train.err
fi

if [ -f train.out ]
then rm train.out
fi

name=`basename $PWD`
job_id=$(qsub -v PATH -terse -N $name $queue_script $python_script $@)
echo "Submitted job $job_id to queue as $name"

# for wandb sync
if $sync
then
    nohup sync_wandb.sh $job_id &
fi