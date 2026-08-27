# 1. Install and load the necessary library
if (!requireNamespace("writexl", quiet = TRUE)) install.packages("writexl")
library(writexl)

#' Convert QIIME2 Metadata TSV to Samples XLSX
#'
#' This function reads a .tsv metadata file, handles QIIME2 type headers,
#' and exports the clean data to an Excel file named "Samples.xlsx".
#'
#' @param input_file Character. Path to the metadata.tsv file.
#' @param output_file Character. Path for the resulting .xlsx file.
#'
#' @return Saves an Excel file in the working directory.
generate_samples_xlsx <- function(input_file = "", output_file = "Samples.xlsx") {
  
  # Check if the file exists
  if (!file.exists(input_file)) {
    stop(paste("Error: File", input_file, "not found."))
  }
  
  # 2. Read the TSV file
  # Note: QIIME2 metadata uses '\t' as separator.
  # We read it initially to check for the #q2:types row.
  raw_metadata <- read.table(input_file, sep = "\t", header = TRUE, check.names = FALSE, stringsAsFactors = FALSE)
  
  # 3. Clean QIIME2 specific type row
  # Usually, the first row of data starts with #q2:types or similar.
  # We filter out any rows where the first column (Sample ID) starts with '#'
  clean_metadata <- raw_metadata[!grepl("^#", raw_metadata[[1]]), ]
  
  # 4. Rename the first column to "SampleID" if preferred, or keep original
  # Based on standard structure, let's ensure the first column is named clearly
  colnames(clean_metadata)[1] <- "SampleID"
  
  # 5. Write to XLSX
  write_xlsx(clean_metadata, path = output_file)
  
  message(paste("Success! Metadata converted to:", output_file))
  message(paste("Total samples processed:", nrow(clean_metadata)))
}

# --- Execution ---
# Simply run the following line in your terminal/R script:
# generate_samples_xlsx()