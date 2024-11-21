#!/bin/bash
#SBATCH --time=00:01:00
#SBATCH --mem=500M
#SBATCH --cpus-per-task=1
#SBATCH --job-name=get_samplelist
# Redirect output and error to the parent directory's 'output' folder
#SBATCH --output=../output/samplelist.tsv   # Standard output
#SBATCH --error=../logfiles/%x-%j.err    # Standard error

# recommended partition is pibu_el8, stick with it if not needed otherwise
#SBATCH --partition=pibu_el8

#first argument passed to the bashscript should be the path to the rawdata
#for this course as first argument:
# /data/users/aballah/rnaseq_course/reads/
FASTQ_FOLDER=$1

for FILE in "${FASTQ_FOLDER}"*_R1.fastq.gz
do
    FILENAME=$(basename "${FILE}")
    SAMPLENAME="${FILENAME%%_*}"
    echo -e "${SAMPLENAME}\t${SAMPLENAME}_R1.fastq.gz\t${SAMPLENAME}_R2.fastq.gz"
done


# derived from the given get_samplelist.sh for this course:
#FASTQ_FOLDER=$1

#loop over all R1 files (the naming for R1 and R2 is the same)
#for FILE in $FASTQ_FOLDER/*_*1.fastq.gz
##do 
#     PREFIX="${FILE%_*.fastq.gz}"
#     SAMPLE=`basename $PREFIX`
#     echo -e "${SAMPLE}\t$FILE\t${FILE%?.fastq.gz}2.fastq.gz" 
# done