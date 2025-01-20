# Submit the python script to the queue and gives it the name of the current folder in the queue
# Use the -s flag to keep this process running until it finishes and sync training data to wandb


python_script="/home/lpetersen/kgcnn_fork/calc_prediction_std.py"

queue_script="/home/user7/sneff/scripts/qpython.sh"

print_usage() {
  echo "Usage: 'submit_python_file.sh' to run without wandb or 'submit_python_file.sh -s' to sync to wandb"
}

sync=false
config_path=""
while getopts ':p:c:s' flag; do
  case $flag in
    p)
      python_script="$OPTARG";;
    s) sync=true ;;
    c)
      config_path="$OPTARG"
      echo "Using configs: $config_path";;
    \?)
      echo "Invalid option: -$OPTARG"
      print_usage
      exit 1;;
    :)
      echo "Option -$OPTARG requires an argument."
      print_usage
      exit 1;;
    *) print_usage
       exit 1 ;;
  esac
done


echo "Using Python file: $python_script"
if [ -z "$config_path" ]
then echo "INFO: Did not get a config_file"
else echo "Using config file: $config_path"
fi

if [ -f train.err ]
then rm train.err
fi

if [ -f train.out ]
then rm train.out
fi

name=`basename $PWD`
job_id=$(qsub -terse -N $name $queue_script $python_script $config_path)
echo "Submitted job $job_id to queue as $name"

# for wandb sync
if $sync
then
    nohup sync_wandb.sh $job_id &
fi
