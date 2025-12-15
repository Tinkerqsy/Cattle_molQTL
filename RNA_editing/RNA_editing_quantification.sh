#!/bin/bash
# RNA editing quantification using REDItools2
# Input : sorted BAM files
# Output: RNA editing phenotype BED file for QTL mapping

############################
# Parameters
############################
BAM_DIR=/path/to/bam_files
REF_FASTA=/path/to/reference.fa
OUT_DIR=./rna_editing
REDITools=/path/to/reditools.py
THREADS=1

mkdir -p ${OUT_DIR}/edit_sites

############################
# Step 1: Run REDItools2
############################
for bam in ${BAM_DIR}/*.bam; do
    sample=$(basename ${bam} .bam)
    echo "[INFO] Processing ${sample}"

    samtools index -@ 2 ${bam}

    python ${REDITools} \
        -f ${bam} \
        -r ${REF_FASTA} \
        -o ${OUT_DIR}/edit_sites/${sample}.edit.txt \
        -t ${THREADS} \
        -S \
        --min_coverage 10 \
        --min_base_quality 30 \
        --min_mapping_quality 40 \
        --output_edited_sites
done

############################
# Step 2: Build editing matrix (A>G / T>C)
############################
Rscript - <<'EOF'
library(data.table)
library(dplyr)

indir <- "rna_editing/edit_sites"
files <- list.files(indir, pattern="\\.edit\\.txt$", full.names=TRUE)

edit_list <- list()

for (f in files) {
  sample <- sub("\\.edit\\.txt$", "", basename(f))
  dt <- fread(f, data.table=FALSE)

  colnames(dt)[1:9] <- c("Region","Position","Reference","Strand",
                         "Coverage","MeanQ","BaseCount",
                         "AllSubs","Frequency")

  dt <- dt %>%
    filter(Coverage >= 10,
           Frequency >= 0.1, Frequency < 1,
           (Reference=="A" & substr(AllSubs,2,2)=="G" & Strand==1) |
           (Reference=="T" & substr(AllSubs,2,2)=="C" & Strand==2)) %>%
    mutate(chr = paste0("chr", Region),
           start = Position - 1,
           end = Position,
           ID = paste0(chr,":",Position,":",Reference,">",substr(AllSubs,2,2))) %>%
    select(chr,start,end,ID,Frequency)

  colnames(dt)[5] <- sample
  edit_list[[sample]] <- dt
}

merged <- Reduce(function(x,y)
  full_join(x,y,by=c("chr","start","end","ID")), edit_list)

merged[is.na(merged)] <- 0
merged <- merged %>% arrange(chr,start)

fwrite(merged,
       file="rna_editing/editing_matrix.bed",
       sep="\t", quote=FALSE)
EOF

############################
# Step 3: Sort & index BED
############################
bgzip -c ${OUT_DIR}/editing_matrix.bed > ${OUT_DIR}/editing_matrix.bed.gz
tabix -p bed ${OUT_DIR}/editing_matrix.bed.gz

echo "[INFO] RNA editing quantification finished."
