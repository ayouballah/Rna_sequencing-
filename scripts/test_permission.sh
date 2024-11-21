#!/bin/bash
#SBATCH --array=1-12
#SBATCH --time=00:01:00
#SBATCH --mem=1g
#SBATCH --cpus-per-task=1
#SBATCH --job-name=quality_control
#SBATCH --output=../logfiles/QC_%J.out   # Standard output
#SBATCH --error=../logfiles/QC_%J.err    # Standard error
#SBATCH --partition=pibu_el8

touch /data/users/aballah/rnaseq_course/logfiles/testfile
