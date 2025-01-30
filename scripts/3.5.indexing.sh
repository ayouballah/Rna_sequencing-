#!/bin/bash
#SBATCH --array=1-12
#SBATCH --time=02:00:00
#SBATCH --mem=32g
#SBATCH --cpus-per-task=8
#SBATCH --job-name=indexing
#SBATCH --output=../logfiles/indexing_%J_%a.out   # Standard output
#SBATCH --error=../logfiles/indexing_%J_%a.err    # Standard error
#SBATCH --partition=pibu_el8

# Define variables
SAMTOOLS_IMAGE="/containers/apptainer/hisat2_samtools_408dfd02f175cd88.sif"
WORKDIR="/data/users/aballah/rnaseq_course"
SAMPLELIST="${WORKDIR}/output/samplelist.tsv"
SORT_BAM_DIR="/data/users/aballah/rnaseq_course/output/sorting"
OUTDIR="${WORKDIR}/output/indexing"
SAMPLELIST="${WORKDIR}/output/samplelist.tsv"

mkdir -p "${OUTDIR}"


SAMPLE=$(awk -v line=${SLURM_ARRAY_TASK_ID} 'NR==line{print $1; exit}' ${SAMPLELIST})

# Define input and output files
SORT_BAM="${SORT_BAM_DIR}/${SAMPLE}_sorted.bam"
INDEX_FILE="${OUTDIR}/${SAMPLE}_sorted.bam.bai"
 
# Run Samtools index
apptainer exec --bind /data ${SAMTOOLS_IMAGE} samtools index \
    -o  ${INDEX_FILE} \
    ${SORT_BAM}
