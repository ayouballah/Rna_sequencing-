#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mem=64g
#SBATCH --cpus-per-task=32
#SBATCH --job-name=feature_count
#SBATCH --output=../logfiles/feature_count_%J.out   # Standard output
#SBATCH --error=../logfiles/feature_count_%J.err    # Standard error
#SBATCH --partition=pibu_el8

FEATURECOUNT_IMAGE="/containers/apptainer/subread_2.0.1--hed695b0_0.sif"

# Define variables
WORKDIR="/data/users/aballah/rnaseq_course"
MAPPING="${WORKDIR}/output/sorting"
OUTDIR="${WORKDIR}/output/feature_count"
SAMPLELIST="${WORKDIR}/output/samplelist.tsv"

# Create output directory
mkdir -p "${OUTDIR}"

# Prepare input BAM files
INPUT_BAMS=$(awk '{print "'"${MAPPING}"'/"$1"_sorted.bam"}' ${SAMPLELIST} | tr '\n' ' ')
OUTPUT_COUNTS="${OUTDIR}/all_FeatureCounts.txt"

# Run featureCounts
#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=32
#SBATCH --job-name=featureCounts
#SBATCH --output=logfiles/featureCounts_%j.out
#SBATCH --error=logfiles/featureCounts_%j.err

apptainer exec --bind /data /containers/apptainer/subread_2.0.1--hed695b0_0.sif featureCounts \
    -T 32 \
    -p \
    -C \
    -s 0 \
    -Q 20 \
    -t exon \
    -g gene_id \
    -a "${WORKDIR}/reference/Homo_sapiens.GRCh38.113.gtf" \
    -G "${WORKDIR}/reference/Homo_sapiens.GRCh38.dna.primary_assembly.fa" \
    -o "${OUTPUT_COUNTS}" \
    ${INPUT_BAMS}
