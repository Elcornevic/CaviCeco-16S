library(writexl)
library(readxl)
library(dplyr)

#' Universal Stacked OTU Matrix Merger
#' 
#' This version is universal. It uses the Metadata file to identify
#' sample names and automatically detects new headers regardless of their 
#' prefix (m, Sample, Case, etc.) or position in the file.
generate_otu_xlsx <- function(input_txt = "", 
                                    metadata_file = "", 
                                    output_xlsx = "OTU_matrix.xlsx") {
  
  if (!file.exists(input_txt) || !file.exists(metadata_file)) {
    stop("Required input files not found.")
  }
  
  # 1. Load the master sample list from metadata
  meta_df <- read_excel(metadata_file)
  all_samples <- as.character(meta_df[[1]]) 
  num_total_samples <- length(all_samples)
  
  # 2. Read raw lines
  raw_lines <- readLines(input_txt)
  
  # 3. Initialize storage
  otu_env <- new.env(hash = TRUE)
  asv_order <- c()
  current_block_samples <- c()
  
  message("Starting universal file processing...")
  
  for (i in 1:length(raw_lines)) {
    line_trimmed <- trimws(raw_lines[i])
    if (line_trimmed == "") next
    
    # Split by any whitespace
    parts <- unlist(strsplit(line_trimmed, "\\s+"))
    
    # --- UNIVERSAL BLOCK DETECTION ---
    # We check how many words in this line match our Metadata sample list.
    # If more than 2 samples match, it's definitely a header line.
    matches_meta <- parts %in% all_samples
    if (sum(matches_meta) > 2) {
      current_block_samples <- parts[matches_meta]
      message(paste("New block detected with", length(current_block_samples), "samples."))
      next
    }
    
    # --- DATA PROCESSING ---
    asv_id <- parts[1]
    # ASV IDs are typically long hexadecimal strings
    if (nchar(asv_id) >= 30) {
      counts <- as.numeric(parts[2:length(parts)])
      counts[is.na(counts)] <- 0
      
      # Initialize OTU if new
      if (!exists(asv_id, envir = otu_env)) {
        row_vec <- setNames(rep(0, num_total_samples), all_samples)
        assign(asv_id, row_vec, envir = otu_env)
        asv_order <- c(asv_order, asv_id)
      }
      
      temp_vec <- get(asv_id, envir = otu_env)
      
      # Universal Mapping: Map counts to the samples identified in the current block
      # This works even if the blocks have different numbers of columns
      for (j in 1:length(counts)) {
        if (j <= length(current_block_samples)) {
          s_name <- current_block_samples[j]
          temp_vec[s_name] <- counts[j]
        }
      }
      
      assign(asv_id, temp_vec, envir = otu_env)
    }
  }
  
  # 4. Final Assembly
  data_list <- lapply(asv_order, function(id) get(id, envir = otu_env))
  otu_matrix <- do.call(rbind, data_list)
  
  # 5. Professional sequential IDs
  num_otus <- nrow(otu_matrix)
  otu_ids <- paste0("OTU", sprintf("%04d", 1:num_otus))
  
  # 6. Assembly and Export
  final_df <- data.frame(OTU = otu_ids, otu_matrix, check.names = FALSE)
  write_xlsx(final_df, path = output_xlsx)
  
  message("--------------------------------------------------")
  message(paste("Success! Processed", num_otus, "OTUs."))
  message(paste("Matrix unified across all detected blocks."))
  message("--------------------------------------------------")
}

# --- Execution ---
# Simply run the following line in your terminal/R script:
# generate_otu_xlsx()