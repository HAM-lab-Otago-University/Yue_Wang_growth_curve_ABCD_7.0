# submit an array job per dataset to process datasets and batches in parallel

# there are 21 site left in the cleaned dataset
N_BATCHES=21


for DATASET in  neuro_all.RDS 
do      
  DATANAME=$(basename $DATASET .RDS)
  JOBID_1=$(sbatch -J neuro_xgb_smri.${DATANAME} --array=1-${N_BATCHES} neuro_xgb_smri.sh ${DATASET} )
  JOBID_1=$(echo $JOBID_1 | awk '{print $4}')
  echo "Job submitted: dataset=$DATASET arraysize=$N_BATCHES job=$JOBID_1"
  

done