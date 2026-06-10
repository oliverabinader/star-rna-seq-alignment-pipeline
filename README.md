# Author: Oliver Abinader



# STAR RNA-seq Alignment Pipeline

A reproducible workflow for bulk RNA-seq analysis using the **STAR aligner**. This pipeline includes genome indexing, read alignment, post-processing (sorting, indexing, deduplication), and downstream gene-level quantification.


## Overview

This pipeline processes paired-end RNA-seq data through the following stages:

1. STAR genome index generation
2. Read alignment
3. BAM file processing (sorting + indexing)
4. Duplicate marking
5. Format conversion (BAM → BED)
6. Gene-level read quantification


# 1. STAR Genome Indexing

The reference genome is indexed using STAR to enable fast and accurate alignment.

Key parameters:

* `sjdbOverhang = read length - 1`

This step builds an indexed genome required for alignment.


# 2. Read Alignment

Paired-end FASTQ files are aligned to the reference genome using STAR.

Key features:

* Multi-threaded alignment (`runThreadN`)
* In-memory genome loading for speed (`genomeLoad LoadAndKeep`)
* Sorted BAM output generation

Output:

* Sorted, coordinate-based BAM files


# 3. BAM Processing

Aligned BAM files are processed for downstream compatibility:

* Sorting (if required)
* Indexing for fast access

This ensures compatibility with downstream analysis tools.


# 4. Duplicate Marking

PCR duplicates are identified and optionally removed using Picard.

Outputs include:

* Deduplicated BAM file
* Duplication metrics report

This improves downstream quantification accuracy.


# 5. Format Conversion

BAM files are converted into alternative formats:

* SAM (for inspection)
* BED (for interval-based analysis)

These formats support downstream genomic coverage analysis.


# 6. Gene-Level Quantification

Gene expression is estimated using coverage against annotated gene regions.

This step calculates:

* Read overlap per gene
* Gene-level coverage statistics


## Key Outputs

* Aligned BAM files
* Indexed BAM files
* Deduplicated BAM files
* BED files
* Gene coverage tables
