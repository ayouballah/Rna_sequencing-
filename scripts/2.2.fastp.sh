#!/bin/bash
#SBATCH --array=1-12
#SBATCH --time=00:30:00
#SBATCH --mem=8G
#SBATCH --cpus-per-task=4
#SBATCH --job-name=fastp
#SBATCH --output=../logfiles/fastp_%J_%a.out   # Standard output
#SBATCH --error=../logfiles/fastp_%J_%a.err    # Standard error
#SBATCH --partition=pibu_el8

# Define variables
WORKDIR="/data/users/aballah/rnaseq_course"
OUTDIR="${WORKDIR}/output/fastp"
SAMPLELIST=/data/users/aballah/rnaseq_course/output/samplelist.tsv

# Extract sample information
SAMPLE=$(awk -v line=$SLURM_ARRAY_TASK_ID 'NR==line{print $1; exit}' $SAMPLELIST)
READ1=$(awk -v line=$SLURM_ARRAY_TASK_ID 'NR==line{print $2; exit}' $SAMPLELIST)
READ2=$(awk -v line=$SLURM_ARRAY_TASK_ID 'NR==line{print $3; exit}' $SAMPLELIST)

#for the analysis fastp version 0.23.2 was used
FASTP_IMAGE="/containers/apptainer/fastp_0.23.2--h5f740d0_3.sif"
#load the fastp module
#bind your specific folder for rerun
apptainer exec --bind /data ${FASTP_IMAGE} fastp \
    --dont_overwrite \
    -h "${OUTDIR}/${SAMPLE}_fastp.html" \
    --detect_adapter_for_pe \
    -i "${WORKDIR}/reads/${READ1}" \
    -I "${WORKDIR}/reads/${READ2}" \
    -o "${OUTDIR}/${SAMPLE}_fastp__R1.fastq.gz" \
    -O "${OUTDIR}/${SAMPLE}_fastp__R2.fastq.gz"