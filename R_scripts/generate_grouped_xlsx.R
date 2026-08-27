# 1. Load necessary libraries
if (!requireNamespace("writexl", quiet = TRUE)) install.packages("writexl")
if (!requireNamespace("readxl", quiet = TRUE)) install.packages("readxl")
library(writexl)
library(readxl)
library(dplyr)

#' Universal Group Aggregator with Error Handling
#' 
#' @param counts_input Path to the CSV (e.g., "sample_size_per_species.csv")
#' @param metadata_input Path to the Excel (e.g., "Samples.xlsx")
#' @param output_name Desired name for the output Excel file
generate_grouped_xlsx <- function(counts_input, metadata_input, output_name = "sample_size_per_groups.xlsx") {
  
  # 1. Error Handling: File Existence Check
  if (!file.exists(counts_input)) {
    stop(paste("Error: The file '", counts_input, "' was not found in:", getwd()))
  }
  if (!file.exists(metadata_input)) {
    stop(paste("Error: The file '", metadata_input, "' was not found in:", getwd()))
  }
  
  # 2. Load Data
  # check.names = FALSE is vital to keep IDs like "m35" from becoming "Xm35"
  counts_df <- read.csv(counts_input, check.names = FALSE, stringsAsFactors = FALSE)
  metadata_df <- read_excel(metadata_input)
  
  # 3. Aggregation Logic
  unique_groups <- unique(metadata_df$group)
  grouped_results <- list()
  
  for (grp in unique_groups) {
    # Get IDs for this specific group
    relevant_ids <- metadata_df %>% 
      filter(group == grp) %>% 
      pull(SampleID)
    
    # Match metadata IDs with CSV column headers
    matching_cols <- intersect(as.character(relevant_ids), colnames(counts_df))
    
    if (length(matching_cols) > 0) {
      if (length(matching_cols) == 1) {
        grouped_results[[grp]] <- counts_df[[matching_cols]]
      } else {
        # Sum counts across the group
        grouped_results[[grp]] <- rowSums(counts_df[, matching_cols, drop = FALSE])
      }
    } else {
      # Fill with 0s if a group in metadata has no matching columns in CSV
      grouped_results[[grp]] <- rep(0, nrow(counts_df))
    }
  }
  
  # 4. Final Export
  final_df <- as.data.frame(grouped_results, check.names = FALSE)
  write_xlsx(final_df, path = output_name)
  
  message(paste("Success! Aggregated", length(unique_groups), "groups."))
  message(paste("Result saved to:", output_name))
}

# --- How to run ---
# generate_grouped_xlsx("sample_size_per_species.csv", "samples.xlsx")