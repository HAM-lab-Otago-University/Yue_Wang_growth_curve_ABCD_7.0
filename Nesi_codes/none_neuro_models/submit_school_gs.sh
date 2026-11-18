# submit an array job per dataset to process datasets and batches in parallel

# there are 21 site left in the cleaned dataset
N_BATCHES=21


for DATASET in  neuro_all.RDS 
do      
  DATANAME=$(basename $DATASET .RDS)
  JOBID_1=$(sbatch -J school_gs.${DATANAME} --array=1-${N_BATCHES} school_gs.sh ${DATASET} )
  JOBID_1=$(echo $JOBID_1 | awk '{print $4}')
  echo "Job submitted: dataset=$DATASET arraysize=$N_BATCHES job=$JOBID_1"
  

done