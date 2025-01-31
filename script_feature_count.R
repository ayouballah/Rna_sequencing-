# Set working directory
setwd("C:/Users/ayoub/Documents/WS_24/rna_seq/feature_count")

# Read the FeatureCounts output file
feature_counts <- read.table("all_FeatureCounts.txt", header = TRUE, sep = "\t")

# Remove the first line and unwanted columns (Chr, Start, End, Strand, Length)
# Keep only the first column (gene IDs) and count data (columns 7 onwards)
counts_matrix <- feature_counts[, c(1, 7:ncol(feature_counts))]

# Write the cleaned data to a new file
write.table(counts_matrix, "counts_matrix.txt", sep = "\t", quote = FALSE, row.names = FALSE)

# Confirmation message
cat("Processed counts matrix saved to counts_matrix.txt in", getwd(), "\n")

library(DESeq2)

# Read counts matrix
counts <- read.table("counts_matrix.txt", header = TRUE, row.names = 1)

# Define experimental design
coldata <- data.frame(
  row.names = colnames(counts),
  group = c("HER2", "HER2", "HER2", "NonTNBC","NonTNBC", "NonTNBC", "Normal", "Normal", "Normal", "TNBC", "TNBC", "TNBC")  
)

# Create DESeqDataSet object
dds <- DESeqDataSetFromMatrix(countData = counts, colData = coldata, design = ~ group)
dds <- DESeq(dds)
vst_data <- vst(dds, blind = TRUE)
# Plot PCA
plotPCA(vst_data, intgroup = "group")

# Extract results for the pairwise comparison
res <- results(dds, contrast = c("group", "TNBC", "NonTNBC"))
# getting significant genes
sig_genes <- res[!is.na(res$padj) & res$padj < 0.05, ]# number of significant genes is 1667 
# Up-regulated genes (LFC > 0)
upregulated <- sig_genes[sig_genes$log2FoldChange > 0, ]# number of up-regulated is 764
# Down-regulated genes (LFC < 0)
downregulated <- sig_genes[sig_genes$log2FoldChange < 0, ] # number of down-regulated is 903
 
# prep for visualization 
res_df <- as.data.frame(res)
res_df$significance <- ifelse(
  res_df$padj < 0.05 & res_df$log2FoldChange > 0, "Upregulated",
  ifelse(res_df$padj < 0.05 & res_df$log2FoldChange < 0, "Downregulated", "Not significant")
)

library(biomaRt)
ensembl <- useMart("ensembl", dataset = "hsapiens_gene_ensembl")

# Query gene symbols for the Ensembl IDs in your dataset
gene_ids <- rownames(res_df)  
gene_annotations <- getBM(attributes = c("ensembl_gene_id", "external_gene_name"),
                          filters = "ensembl_gene_id",
                          values = gene_ids,
                          mart = ensembl)
#naming the column for the genes 
res_df$ensembl_gene_id <- rownames(res_df)
# Merge with your results to add gene symbols
res_with_symbols <- merge(res_df, gene_annotations, by = "ensembl_gene_id", all.x = TRUE)

# View the first few rows of the results with gene symbols
head(res_with_symbols)

library(EnhancedVolcano)

# Define color scheme
keyvals <- ifelse(
  res_with_symbols$log2FoldChange < -1 & res_with_symbols$padj < 0.05, "blue",
  ifelse(res_with_symbols$log2FoldChange > 1 & res_with_symbols$padj < 0.05, "red", "grey")
)

names(keyvals) <- ifelse(
  res_with_symbols$log2FoldChange < -1 & res_with_symbols$padj < 0.05, "Downregulated",
  ifelse(res_with_symbols$log2FoldChange > 1 & res_with_symbols$padj < 0.05, "Upregulated", "Not significant")
)

# Create volcano plot
EnhancedVolcano(res_with_symbols,
                lab = res_with_symbols$external_gene_name,  # Gene names as labels
                x = 'log2FoldChange',
                y = 'padj',  
                pCutoff = 0.05,
                FCcutoff = 1,
                title = "Volcano Plot for TNBC vs NonTNBC",
                xlab = "Log2 Fold Change",
                ylab = "-Log10 p-value",
                subtitle = "DE Genes with Gene Symbols",
                colCustom = keyvals,  
                legendLabels = c("Not significant", "Downregulated", "Upregulated")
)

library(clusterProfiler)

# Use the gene symbols from the merged data frame for enrichment analysis
de_genes <- res_with_symbols$external_gene_name[!is.na(res_with_symbols$external_gene_name) & res_with_symbols$padj < 0.05]

# Run enrichment analysis (GO terms)
go_enrich <- enrichGO(de_genes, OrgDb = org.Hs.eg.db, keyType = "SYMBOL", ont = "BP", pAdjustMethod = "BH", pvalueCutoff = 0.05)

# Visualize results
bar <- barplot(go_enrich, showCategory = 10)
dot <- dotplot(go_enrich, showCategory = 10)

library(patchwork)
dot+bar

# Genes of interest
genes_of_interest <- c("ESR1", "ELF1", "AGR3")  

# Subset counts data for genes of interest
counts_subset <- counts[genes_of_interest, ]

# Combine counts data with experimental group information
counts_subset_long <- as.data.frame(t(counts_subset))
counts_subset_long$group <- coldata$group

# Plot boxplots for gene expression
library(ggplot2)
ggplot(counts_subset_long, aes(x = group, y = gene1, fill = group)) +
  geom_boxplot() +
  labs(title = "Gene1 Expression Across Groups", x = "Group", y = "Expression") +
  theme_bw()
#__________________________________________________________________________________________
# Sort the results by padj (adjusted p-value) and log2FoldChange
top_genes <- res[order(res$padj, abs(res$log2FoldChange)), ]

# Extract top 10 genes
top_10_genes <- head(top_genes, 11)

# Convert to a data frame for better readability
top_10_genes_df <- as.data.frame(top_10_genes)
top_10_genes_with_names <- merge(top_10_genes_df, gene_annotations, by = "ensembl_gene_id", all.x = TRUE)

# View the table of top 10 genes
print(top_10_genes_with_names)



# Ensure that the 'ensembl_gene_id' column is added to the top genes dataframe
top_10_genes_df$ensembl_gene_id <- rownames(top_10_genes_df)

# Now merge with gene annotations
top_10_genes_with_names <- merge(top_10_genes_df, gene_annotations, by = "ensembl_gene_id", all.x = TRUE)

# View the table of top 10 genes with gene names
print(top_10_genes_with_names)


# Get normalized counts
normalized_counts <- counts(dds, normalized = TRUE)

# Select genes of interest (in order: ELF5, AGR2, ESR1)
genes_of_interest <- c("ENSG00000135374", "ENSG00000106541", "ENSG00000091831") 

# Check if the selected genes are present in the dataset
selected_genes_counts <- normalized_counts[rownames(normalized_counts) %in% genes_of_interest, ]

# Print the selected genes and check if data is available: ENSG00000135374 = ELF5, ENSG00000106541 = ROPN1b, ENSG00000065371 = AGR2, ENSG00000091831 = ESR1
print(selected_genes_counts)








