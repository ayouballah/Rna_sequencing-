#!/bin/bash
#SBATCH --array=1-12
#SBATCH --time=14:30:00
#SBATCH --mem=128g
#SBATCH --cpus-per-task=8
#SBATCH --job-name=mapping
#SBATCH --output=../logfiles/mapping_%J_%a.out
#SBATCH --error=../logfiles/mapping_%J_%a.err
#SBATCH --partition=pibu_el8

# Paths and variables
HISAT2_IMAGE="/containers/apptainer/hisat2_samtools_408dfd02f175cd88.sif"
SAMTOOLS_IMAGE="/containers/apptainer/hisat2_samtools_408dfd02f175cd88.sif"
WORKDIR="/data/users/aballah/rnaseq_course"
INDEXING="${WORKDIR}/output/indexing_reference"
OUTDIR="${WORKDIR}/output/mapping00"
SAMPLELIST="${WORKDIR}/output/samplelist.tsv"
FASTQ_DIR="${WORKDIR}/output/fastp"

# Get sample information
SAMPLE=$(awk -v line=${SLURM_ARRAY_TASK_ID} 'NR==line {print $1}' ${SAMPLELIST})
READ1="${FASTQ_DIR}/${SAMPLE}_fastp__R1.fastq.gz"
READ2="${FASTQ_DIR}/${SAMPLE}_fastp__R2.fastq.gz"

# Debugging output
echo "Processing sample: ${SAMPLE}"
echo "READ1 path: ${READ1}"
echo "READ2 path: ${READ2}"

# Check if FASTQ files exist
if [[ ! -f "${READ1}" || ! -f "${READ2}" ]]; then
    echo "Error: One or both FASTQ files for sample ${SAMPLE} are missing. Exiting."
    exit 1
fi

# Mapping with HISAT2
apptainer exec --bind /data ${HISAT2_IMAGE} hisat2 \
    -p 8 \
    -x ${INDEXING}/GRCh38_index \
    -1 ${READ1} \
    -2 ${READ2} \
    -S ${OUTDIR}/${SAMPLE}_aligned.sam

# Convert SAM to BAM
apptainer exec --bind /data ${SAMTOOLS_IMAGE} samtools view \
    -S \
    -b ${OUTDIR}/${SAMPLE}_aligned.sam > ${OUTDIR}/${SAMPLE}_aligned.bam

# Clean up
rm ${OUTDIR}/${SAMPLE}_aligned.sam
