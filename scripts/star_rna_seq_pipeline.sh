#!/bin/bash

set -euo pipefail

########################################################
# USAGE
########################################################
# bash star_rna_seq_pipeline.sh <mode> <args...>
#
# MODE 1: index
# bash script.sh index <genome_dir> <fasta> <gtf>
#
# MODE 2: align
# bash script.sh align <genome_dir> <R1> <R2> <out_prefix>
#
# MODE 3: postprocess
# bash script.sh postprocess <bam_file>
########################################################

MODE=$1

########################################################
# 1. STAR GENOME INDEXING
########################################################

if [ "$MODE" == "index" ]; then

    GENOME_DIR=$2
    FASTA=$3
    GTF=$4

    echo "Step 1: Building STAR genome index..."

    STAR --runThreadN 20 \
         --runMode genomeGenerate \
         --genomeDir "$GENOME_DIR" \
         --genomeFastaFiles "$FASTA" \
         --sjdbGTFfile "$GTF" \
         --sjdbOverhang 99 # this value is customizable

    echo "STAR index complete."

########################################################
# 2. STAR ALIGNMENT
########################################################

elif [ "$MODE" == "align" ]; then

    GENOME_DIR=$2
    R1=$3
    R2=$4
    OUT_PREFIX=$5

    echo "Step 2: Running STAR alignment..."

    STAR --genomeLoad LoadAndExit --genomeDir ...
    
    STAR --runThreadN 20 \
         --runMode alignReads \
         --genomeLoad LoadAndKeep \
         --genomeDir "$GENOME_DIR" \
         --readFilesIn "$R1" "$R2" \
         --outSAMtype BAM SortedByCoordinate \
         --limitBAMsortRAM 20000000000 \
         --outFileNamePrefix "$OUT_PREFIX"

    STAR --genomeLoad Remove --genomeDir ...

    echo "Alignment complete."

########################################################
# 3. POST-PROCESSING
########################################################

elif [ "$MODE" == "postprocess" ]; then

    BAM=$2

    echo "Step 3: BAM processing pipeline..."

    ####################################################
    # 3.1 Index BAM
    ####################################################
    echo "Indexing BAM..."
    samtools index "$BAM"

    ####################################################
    # 3.2 Mark duplicates
    ####################################################
    echo "Marking duplicates..."

    OUT_BAM="${BAM%.bam}_deduplicated.bam"
    METRICS="${BAM%.bam}_dup_metrics.txt"

    picard MarkDuplicates \
        I="$BAM" \
        O="$OUT_BAM" \
        M="$METRICS" \
        --REMOVE_DUPLICATES true && \
        
    samtools index $out && picard CollectAlignmentSummaryMetrics -I $bam -R RCh38.p13_genomic.fna -O $aln_met && 
    
    echo "Completed de-duplicating and indexing $bam"'

    ####################################################
    # 3.3 Convert BAM to SAM (optional inspection)
    ####################################################
    echo "Converting BAM to SAM..."
    samtools view "$BAM" > "${BAM%.bam}.sam"

    ####################################################
    # 3.4 Convert BAM to BED
    ####################################################
    echo "Converting BAM to BED..."
    bedtools bamtobed -i "$BAM" > "${BAM%.bam}.bed"

    ####################################################
    # 3.5 Gene-level coverage
    ####################################################
    echo "Computing gene coverage..."

    GTF_REF="protein_coding_genes.gtf"

    bedtools coverage \
        -a "$GTF_REF" \
        -b "${BAM%.bam}.bed" \
        > "${BAM%.bam}.gene_coverage.bed"

    echo "Post-processing complete."

else
    echo "Invalid mode. Use: index | align | postprocess"
    exit 1
fi


this next stepo could be a seprate downstream thing in rna seq 
IGV plots
	•	Filter reads from original BAM files aligning to mitochondria (it becomes mitochondrial filtering only if the BED file contains mitochondrial regions)
ls *.bam | parallel -j 10 'in={} out=${in%.bam}_mito.bam; samtools view -L GCF_000001405.39_GRCh38.p13_genomic.mito.bed -b $in -o $out && \
echo "Completed filtering mito reads for $in"' 
	•	Index BAM files (ls *_mito.bam | parallel -j 16 ‘samtools index {}’) 
	•	Copy resulting BAM and BAI files into local 
	•	Go to IGV browser and upload the BAM files as tracks


This extracts only reads from BAM files that align to chromosome 21 using the RefSeq chromosome identifier (NC_000021.9), 
and saves them as separate BAM files for visualization or downstream analysis (e.g., IGV).
command 
ls *.bam | parallel -j 10 '
in={}
out=${in%.bam}_chr21.bam
samtools view -h "$in" NC_000021.9 | samtools view -bS - > chr21/"$out"
'
