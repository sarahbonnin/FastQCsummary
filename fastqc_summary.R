#!/usr/bin/R

## Script called by fastqc_summary.sh as: Rscript fastqc_summarize_all.R FastQC_allsamples_summary.txt FastQC_table_summary.txt

## Install required packages, if needed
list.of.packages <- c("ggplot2", "reshape2", "WriteXLS")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

## Load packages
library(c("ggplot2", "reshape2", "WriteXLS"))

## Plot matrix of pass / warn / fail, to get a summary per project

# retrieve command line arguments
args <- commandArgs(trailingOnly =TRUE)

# read matrix allsamples_summary created by script fastqc_summarize.sh
mat.fastqc <- read.table(args[[1]], sep="\t", header=T, as.is=T)
rownames(mat.fastqc) <- mat.fastqc$Sample
mat.fastqc <- mat.fastqc[,-grep("Sample", colnames(mat.fastqc))]

# melt to ggplot long format
df <- melt(t(mat.fastqc))

# geom_tile: heatmap-like; filling colors are peaks
p <- ggplot(df, aes(x=Var2, y=Var1)) + geom_tile(aes(fill=factor(value)))

# change default colors to match FastQC ones
col.sel=c("darkred", "forestgreen", "darkorange3")

# adjust color scale, add legend
p <- p + scale_fill_manual(name = "value", 
                        values = col.sel, 
                        labels=c("Fail","Pass","Warn"))

# rotate x-axis labels
p1 <- p + theme(axis.text.x = element_text(angle = 300, hjust = 0)) + scale_x_discrete(name="") + scale_y_discrete(name="")

# save in file
pdf("FastQC_project_summary.pdf", height=8, width=12)
plot(p1)
dev.off()

## Save table_summary.txt as Excel

mat.summ <- read.table(args[[2]], sep="\t", header=T, as.is=T)

WriteXLS("mat.summ", ExcelFileName="FastQC_table_summary.xls", col.names=T, row.names=F, AdjWidth=T, BoldHeaderRow=T)








