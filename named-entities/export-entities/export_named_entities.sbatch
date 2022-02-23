#!/bin/bash
#SBATCH -J NER
#SBATCH -o NER_%A-%a.out
#SBATCH --array=1-19999
#SBATCH -c 1
#SBATCH --mem=6G
#SBATCH -t 0-2
#SBATCH -p htc,standard-mem-s

module purge
module load python/3

input_file="clean_data.csv"
py_script="export_named_entities.py"

work_directory="${SLURM_JOB_NAME}_${SLURM_ARRAY_JOB_ID}"
csv_chunk=$(printf "/dev/shm/csv_chunk.%d.%05d" ${SLURM_ARRAY_JOB_ID} ${SLURM_ARRAY_TASK_ID})
if [ ${SLURM_ARRAY_TASK_ID} -eq ${SLURM_ARRAY_TASK_MIN} ]; then
    mkdir -p ${work_directory}
    cd ${work_directory}
    cp ../${py_script} .
    tail -n +2 ../${input_file} > csv_no_header.csv
    head -1 ../${input_file} > csv_header
    touch no_header_done
else
    while [ ! -f ${work_directory}/no_header_done ]; do
       sleep 5
    done
    cd ${work_directory}
fi
cat csv_header \
    <(split --number=l/${SLURM_ARRAY_TASK_ID}/${SLURM_ARRAY_TASK_COUNT} \
            csv_no_header.csv) \
    > ${csv_chunk}

python ${py_script} ${csv_chunk}

rm ${csv_chunk}