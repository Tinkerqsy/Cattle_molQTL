#!/bin/bash
# Quantification of alternative splicing using LeafCutter
# Input: sorted BAM files
# Output: normalized splicing phenotype BED file for QTL mapping

BAM_DIR=/path/to/bam_files
OUT_DIR=./output
LEAFCUTTER=/path/to/leafcutter/scripts

mkdir -p ${OUT_DIR}/junc

# Step 1: BAM -> junction files
for bam in ${BAM_DIR}/*.bam; do
    sample=$(basename ${bam} .bam)
    sh ${LEAFCUTTER}/bam2junc.sh ${bam} ${OUT_DIR}/junc/${sample}.junc
done

# Step 2: cluster junctions
ls ${OUT_DIR}/junc/*.junc > ${OUT_DIR}/juncfiles.txt
python2 ${LEAFCUTTER}/../clustering/leafcutter_cluster.py \
    -j ${OUT_DIR}/juncfiles.txt \
    -m 50 -l 50000 -o ${OUT_DIR}/splicing

# Step 3: normalize and prepare phenotype table
python2 ${LEAFCUTTER}/prepare_phenotype_table.py \
    ${OUT_DIR}/splicing_perind.counts.gz -p 10
