#!/usr/bin/env Rscript

##############################################################################

# Project:     Plotting read length distribution
# Author:      Robert Linder
# Date:        2024-06-24
# Title:       plot_read_length_distribution
# Description: Plots the distribution of read lengths. 
# Version:     1.0.0

##############################################################################

# ============================================================================
# Parse command line inputs

args <- commandArgs(trailingOnly=TRUE)
if (length(args) < 2) {
    stop("Usage: plot_read_length_distribution.R <read_lens> <sample_id>", call.=FALSE)
}

rl <-  args[1]
sample_id <- args[2]

# ============================================================================
# Load packages and sourced files
library(tidyverse)
library(cowplot)
library(plyr)

# ============================================================================
# Set global options

options(digits = 10)
projectDir <- getwd()

# ============================================================================
# Custom functions

# ============================================================================
# Load data

read_length_df <- read.delim(rl, sep = ",", header = FALSE)
print(read_length_df)
colnames(read_length_df) <- c("platform", "length")
read_length_df$platform <- as.factor(read_length_df$platform)
levels(read_length_df$platform) <- "PacBio_HiFi"

# ============================================================================
# Calculate average read-lengths 
summary_df <- ddply(read_length_df, "platform", summarise, grp.mean=mean(length))

# ============================================================================
# Plot read-length distribution for all reads 
total.length.plot <- ggplot(read_length_df, aes(x=length, fill=platform, color=platform)) + geom_histogram(binwidth=100, alpha=0.5, position="dodge") + geom_vline(data=summary_df, aes(xintercept=grp.mean, color=platform), linetype="dashed", size =0.2) + scale_x_continuous(labels = comma) + scale_y_continuous(labels = comma) +  labs(x = "Read length (bp)", y = "Count") + theme_bw()

# ============================================================================
# Plot read-length distribution for reads <= 20kb in length 
kb.length.plot <- ggplot(read_length_df, aes(x=length, fill=platform, color=platform)) + geom_histogram(binwidth=50, alpha=0.5, position="dodge") + geom_vline(data=summary_df, aes(xintercept=grp.mean, color=platform), linetype="dashed", size=0.2) + scale_x_continuous(labels = comma, limit = c(0,20000)) + scale_y_continuous(labels = comma) + labs(x = "Read length (bp)", y = "Count") + theme_bw()

# ============================================================================
# Merge the above two plots into a two-panel figure
plot <- plot_grid(total.length.plot, 20 kb.length.plot, ncol = 1)
pdf(paste0(sample_id, ".read.length.pdf"),width=6,height=8,paper='special')
print(plot)
dev.off()