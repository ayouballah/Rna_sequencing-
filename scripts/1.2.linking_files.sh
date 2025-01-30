#!/bin/bash
#SBATCH --time=00:01:00
#SBATCH --mem=500M
#SBATCH --cpus-per-task=1
#SBATCH --job-name=link_rawdata

# Redirect output and error to the parent directory's 'output' folder
#SBATCH --output=../output/%x-%j.out   # Standard output
#SBATCH --error=../output/%x-%j.err    # Standard error

# recommended partition is pibu_el8, stick with it if not needed otherwise
#SBATCH --partition=pibu_el8

mkdir /data/users/aballah/rnaseq_course/data
ln -s /data/courses/rnaseq_course/breastcancer_de/reads/* /data/users/aballah/rnaseq_course/data
