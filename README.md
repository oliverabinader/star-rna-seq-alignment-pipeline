# STAR RNA-seq Alignment and Visualization Pipeline

**Author:** Oliver Abinader

A reproducible workflow for bulk RNA-seq analysis using the STAR aligner. This repository covers genome indexing, read alignment, BAM post-processing, duplicate removal, gene-level quantification, and visualization-oriented BAM extraction for IGV.


# Repository Structure

```text
star-rna-seq-alignment-and-visualization/
│
├── README.md
│
└── scripts/
    └── star_rna_seq_pipeline.sh
```


# Workflow Overview

This workflow processes paired-end RNA-seq data through the following stages:

1. STAR genome index generation
2. Read alignment
3. BAM indexing
4. Duplicate marking
5. Alignment quality metrics
6. BAM to SAM conversion
7. BAM to BED conversion
8. Gene-level quantification
9. Mitochondrial read extraction
10. Chromosome-specific BAM extraction
11. IGV visualization


# 1. STAR Genome Indexing

STAR requires a pre-built genome index before reads can be aligned.

### Key Parameter

**sjdbOverhang = read length - 1**

Examples:

* 100 bp reads → 99
* 150 bp reads → 149

Output:

* STAR genome index directory


# 2. Read Alignment

Paired-end FASTQ files are aligned to the indexed reference genome.

### Features

* Multi-threaded alignment
* Coordinate-sorted BAM output

Output:

* Aligned BAM files
* Alignment metric generation


# 3. BAM Processing

Aligned BAM files are prepared for downstream analyses.

### Steps

* BAM indexing
* Duplicate marking

Outputs:

* Indexed BAM files
* Deduplicated BAM files
* Alignment summary metrics


# 4. Format Conversion

BAM files may be converted into alternative formats for inspection and downstream analyses.

### Supported Conversions

* BAM → SAM
* BAM → BED

Outputs:

* SAM files
* BED files


# 5. Gene-Coverage Quantification

Read coverage is calculated against annotated gene regions.

Outputs:

* Gene-level read counts


# 6. Mitochondrial Read Extraction

Reads overlapping mitochondrial regions can be extracted using a BED file containing mitochondrial coordinates.

Output:

* Mitochondrial BAM files

Applications:

* IGV visualization


# 7. Chromosome-Specific BAM Extraction

Reads aligned to a specific chromosome can be isolated for targeted inspection.

Example:

* Chromosome 21 (RefSeq: NC_000021.9)

Output:

* Chromosome-specific BAM files

Applications:

* Coverage inspection
* Region-specific visualization


# 8. Visualization in IGV

Resulting BAM and BAI files can be loaded into IGV for visual inspection of:

* Read coverage
* Mitochondrial enrichment
* Chromosome-specific signals


# Software Requirements

* STAR
* samtools
* Picard
* bedtools
* GNU Parallel
* IGV
