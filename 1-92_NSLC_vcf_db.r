if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install("GenomicRanges", force = TRUE)
BiocManager::install("VariantAnnotation")
#BiocManager::install("TxDb.Hsapiens.UCSC.hg19.knownGene")
#BiocManager::install("BSgenome.Hsapiens.UCSC.hg19")

#library(TxDb.Hsapiens.UCSC.hg19.knownGene)
#library(BSgenome.Hsapiens.UCSC.hg19)
#txdb <- TxDb.Hsapiens.UCSC.hg19.knownGene
#BSgenome <- BSgenome.Hsapiens.UCSC.hg19

library(readr)
library(GenomicRanges)
library(VariantAnnotation)
library(stringr)
library(tidyr)
library(dplyr)



# Reference : https://bioconductor.org/packages/devel/bioc/vignettes/VariantAnnotation/inst/doc/VariantAnnotation.pdf

# Linux
# VEP.first_line <- grep('##', readLines("/mnt/sda2/TMB/Data/VEP_92_NSLC/NSLC_0001.vcf"), invert = TRUE, fixed = TRUE, )[1]
# VCF.info_lines <- grep('##INFO=', readLines("/mnt/sda2/TMB/Data/VEP_92_NSLC/NSLC_0001.vcf"), fixed = TRUE)
# VEP.format_line <- last(VCF.info_lines)
# VCF.info <- readLines("/mnt/sda2/TMB/Data/VEP_92_NSLC/NSLC_0001.vcf")[c(VCF.info_lines[1:length(VCF.info_lines)-1])] %>% gsub(".*ID=", "", .) %>% gsub(",.*", "", .)
# VEP.format <- readLines("/mnt/sda2/TMB/Data/VEP_92_NSLC/NSLC_0001.vcf")[VEP.format_line] %>% gsub(".*Format: ", "", .) %>% gsub("\">", "", .) %>% str_split(., "\\|") %>% unlist()
# VEP_data <- read.delim("/mnt/sda2/TMB/Data/VEP_92_NSLC/NSLC_0001.vcf", sep = "\t", skip = VEP.first_line-1, header = TRUE)
# Windows
VEP.header <- grep('##', readLines("Data/NSLC_0001.vcf"), invert = TRUE, fixed = TRUE, )[1]
VCF.info_lines <- grep('##INFO=', readLines("Data/NSLC_0001.vcf"), fixed = TRUE)
VEP.format_line <- last(VCF.info_lines)
VCF.info <- readLines("Data/NSLC_0001.vcf")[c(VCF.info_lines[1:length(VCF.info_lines)-1])] %>% gsub(".*ID=", "", .) %>% gsub(",.*", "", .)
VEP.format <- readLines("Data/NSLC_0001.vcf")[VEP.format_line] %>% gsub(".*Format: ", "", .) %>% gsub("\">", "", .) %>% str_split(., "\\|") %>% unlist()
VEP_data <- read.delim("Data/NSLC_0001.vcf", sep = "\t", skip = VEP.first_line-1, header = TRUE)

# Data formatting
VEP.extra <- strsplit(VEP_data$INFO, ";\\s*(?=[^;]+$)", perl=TRUE)
VEP_data$INFO <- sapply(VEP.extra, "[[", 1)
VEP_data$EXTRA <- sapply(VEP.extra, "[[", 2)
VEP_data$EXTRA <- lapply(VEP_data$EXTRA, gsub, pattern = 'CSQ=', replacement='')
VEP_data.EXTRA_split_rows <- separate_rows(VEP_data, EXTRA, sep=",")
VEP_data.EXTRA_split_cols <- separate(VEP_data.EXTRA_split_rows, EXTRA, c(VEP.format), sep = "\\|")


VCF <- keepSeqlevels(VCF, c(1:22, "X", "Y"), pruning.mode = "coarse")
seqlevels(VCF) <- paste0("chr", c(1:22, "X", "Y"))
VCF.range <- rowRanges(VCF)

all.variants <- locateVariants(VCF.range, txdb, AllVariants())

which(all.variants == trim(all.variants))
which(end(all.variants) > seqlengths(BSgenome)[as.character(seqnames(all.variants))])
all.variants[all.variants$QUERYID == 153]



