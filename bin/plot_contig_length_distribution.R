#!/usr/bin/env Rscript

##############################################################################

# Project:     Genome assembly and annotation
# Author:      Robert Linder
# Date:        2024-06-24
# Title:       plot_contig_length_distribution
# Description: Plots the distribution of contig lengths. 
# Version:     1.0.0

##############################################################################

# ============================================================================
# Parse command line inputs

args <- commandArgs(trailingOnly=TRUE)
if (length(args) < 2) {
    stop("Usage: plot_contig_length_distribution.R <contig_lens> <sample_id>", call.=FALSE)
}

cl <-  args[1]
sample_id <- args[2]

# ============================================================================
# Load packages and sourced files
library(tidyverse)
library(cowplot)

# ============================================================================
# Set global options

options(digits = 10)
projectDir <- getwd()

# ============================================================================
# Custom functions

# ============================================================================
# Load data

contig_cumulative_sum_df <- read.delim(cl, sep = ",", header = FALSE)
colnames(contig_cumulative_sum_df) <- c("line", "length", "type", "coverage")
contig_cumulative_sum_df$type <- factor(contig_cumulative_sum_df$type, levels="contig")

# ============================================================================
# Plot contig-length distribution 

plot <- ggplot(data=contig_cumulative_sum_df, aes(x=coverage, y=length/1000000, color=line)) + geom_vline(xintercept = 0.5, linetype="dotted", size=0.5) + xlim(0, 1) + geom_step(aes(linetype=type)) + labs(x = "Cumulative coverage", y = "Length (Mb)")
pdf(paste0(sample_id, "_coverage.pdf"),width=4,height=3,paper='special')
print(plot)
dev.off()