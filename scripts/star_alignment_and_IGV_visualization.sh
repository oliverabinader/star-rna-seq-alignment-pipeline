#!/bin/bash

set -euo pipefail

########################################################
# STAR RNA-seq Alignment and IGV Visualization Pipeline
########################################################

########################################################
# STEP 1: BUILD STAR GENOME INDEX
########################################################
#
# Usage:
# bash star_alignment_and_IGV_visualization.sh index \
# <genome_dir> <fasta> <gtf> <sjdbOverhang>
#
########################################################

if [ "$1" = "index" ]; then

GENOME_DIR=$2
FASTA=$3
GTF=$4
OVERHANG=$5

STAR \
  --runThreadN 20 \
  --runMode genomeGenerate \
  --genomeDir "$GENOME_DIR" \
  --genomeFastaFiles "$FASTA" \
  --sjdbGTFfile "$GTF" \
  --sjdbOverhang "$OVERHANG"

echo "STAR index completed."

########################################################
# STEP 2: ALIGN READS
########################################################

elif [ "$1" = "align" ]; then

GENOME_DIR=$2
R1=$3
R2=$4
OUT_PREFIX=$5

STAR \
  --genomeLoad LoadAndExit \
  --genomeDir "$GENOME_DIR"

STAR \
  --runThreadN 20 \
  --runMode alignReads \
  --genomeLoad LoadAndKeep \
  --genomeDir "$GENOME_DIR" \
  --readFilesIn "$R1" "$R2" \
  --outSAMtype BAM SortedByCoordinate \
  --limitBAMsortRAM 20000000000 \
  --outFileNamePrefix "$OUT_PREFIX"

STAR \
  --genomeLoad Remove \
  --genomeDir "$GENOME_DIR"

echo "Alignment complete."

########################################################
# STEP 3: POSTPROCESS BAM
########################################################

elif [ "$1" = "postprocess" ]; then

BAM=$2
REFERENCE_FASTA=$3

DEDUP_BAM="${BAM%.bam}_deduplicated.bam"
DUP_METRICS="${BAM%.bam}_duplication_metrics.txt"
ALIGN_METRICS="${BAM%.bam}_alignment_metrics.txt"

samtools index "$BAM"

picard MarkDuplicates \
    I="$BAM" \
    O="$DEDUP_BAM" \
    M="$DUP_METRICS" \
    --REMOVE_DUPLICATES true

samtools index "$DEDUP_BAM"

picard CollectAlignmentSummaryMetrics \
    I="$DEDUP_BAM" \
    R="$REFERENCE_FASTA" \
    O="$ALIGN_METRICS"

samtools view "$DEDUP_BAM" \
    > "${DEDUP_BAM%.bam}.sam"

bedtools bamtobed \
    -i "$DEDUP_BAM" \
    > "${DEDUP_BAM%.bam}.bed"

echo "Post-processing complete."

########################################################
# STEP 4: GENE QUANTIFICATION
########################################################

elif [ "$1" = "quantify" ]; then

BED_FILE=$2
GTF_FILE=$3

OUTPUT="${BED_FILE%.bed}.gene_coverage.bed"

bedtools coverage \
    -a "$GTF_FILE" \
    -b "$BED_FILE" \
    > "$OUTPUT"

echo "Gene quantification complete."

########################################################
# STEP 5: EXTRACT MITOCHONDRIAL READS
########################################################

elif [ "$1" = "mito" ]; then

MITO_BED=$2

ls *.bam | parallel -j 10 '
in={}
out=${in%.bam}_mito.bam

samtools view \
    -L '"$MITO_BED"' \
    -b "$in" \
    -o "$out"
'

echo "Mitochondrial filtering complete."

########################################################
# STEP 6: EXTRACT CHROMOSOME 21 READS
########################################################

elif [ "$1" = "chr21" ]; then

mkdir -p chr21

ls *.bam | parallel -j 10 '
in={}
out=${in%.bam}_chr21.bam

samtools view -h "$in" NC_000021.9 |
samtools view -bS - \
> chr21/"$out"
'

echo "Chromosome 21 extraction complete."

else

echo "Usage:"
echo "  index"
echo "  align"
echo "  postprocess"
echo "  quantify"
echo "  mito"
echo "  chr21"

exit 1

fi
