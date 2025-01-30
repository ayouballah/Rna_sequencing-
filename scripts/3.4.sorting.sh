#!/bin/bash
#SBATCH --array=1-12
#SBATCH --time=02:15:00
#SBATCH --mem=144g
#SBATCH --cpus-per-task=8
#SBATCH --job-name=sorting
#SBATCH --output=../logfiles/sorting_%J_%a.out   # Standard output
#SBATCH --error=../logfiles/sorting_%J_%a.err    # Standard error
#SBATCH --partition=pibu_el8

# Get links for the image of samtools
SAMTOOLS_IMAGE="/containers/apptainer/hisat2_samtools_408dfd02f175cd88.sif"

# Define variables
WORKDIR="/data/users/aballah/rnaseq_course"
MAPPING="${WORKDIR}/output/mapping"
OUTDIR="${WORKDIR}/output/sorting"
SAMPLELIST="${WORKDIR}/output/samplelist.tsv"



# Get sample name
SAMPLE=$(awk -v line=${SLURM_ARRAY_TASK_ID} 'NR==line{print $1; exit}' ${SAMPLELIST})
OUTPUT_FILE="${OUTDIR}/${SAMPLE}_sorted.bam"

# Check if the sorted BAM file already exists
if [[ -f "${OUTPUT_FILE}" ]]; then
    echo "Output file ${OUTPUT_FILE} already exists. Skipping sorting for ${SAMPLE}."
    exit 0
fi

# Run samtools sort
echo "Sorting BAM file for ${SAMPLE}..."
apptainer exec --bind /data ${SAMTOOLS_IMAGE} samtools sort \
    -@ 8 \
    -m 12G \
    -o "${OUTPUT_FILE}" \
    "${MAPPING}/${SAMPLE}_aligned.bam"

# Check if sorting was successful
if [[ $? -eq 0 ]]; then
    echo "Sorting completed successfully for ${SAMPLE}. Output: ${OUTPUT_FILE}"
else
    echo "Error occurred while sorting for ${SAMPLE}. Check logs for details."
    exit 1
fi
