##### Load packages #####
library(readxl)
library(SpadeR)
library(vegan)
library(iNEXT)
library(readr)

##### start the analyses #####

##### DIPTERA #####

# Upload OTU data of Diptera
diptera_data <- read_excel("otus_v4.xlsx", sheet = "Diptera")

# Extract family names from the first row, excluding the first column
family_names <- as.character(unlist(diptera_data[1, -1]))

# Get unique family names
unique_family_names <- unique(family_names)

# Create a list to store results for each family
family_results <- list()

# Open a single file for writing all results
file_conn <- file("all_family_results.txt", "w")

# Function to write family results to the combined file
write_family_results <- function(family, sp_id, asap, family_iNEXT) {
  writeLines(paste("Results for family:", family), file_conn)
  writeLines("\nSpecies Identifier Data:", file_conn)
  writeLines(paste(sp_id, collapse = ", "), file_conn)
  writeLines("\nASAP Data:", file_conn)
  writeLines(paste(asap, collapse = ", "), file_conn)
  
  # Writing iNEXT estimates
  writeLines("\n\nEstimates from iNEXT:", file_conn)
  for (datatype in names(family_iNEXT$iNextEst)) {
    writeLines(paste("\nModel:", datatype), file_conn)
    writeLines(capture.output(print(family_iNEXT$iNextEst[[datatype]])), file_conn)
  }
  
  # Writing Chao1 estimates using SpeciesIdentifier
  writeLines("\n\nChao1 Estimates using SpeciesIdentifier:", file_conn)
  writeLines(capture.output(print(Diversity(sp_id, "abundance", q = c(0, 1, 2)))), file_conn)
  writeLines(capture.output(print(ChaoSpecies(sp_id, "abundance", k = 2, conf = 0.95))), file_conn)
  
  # Writing Chao1 estimates using ASAP
  writeLines("\n\nChao1 Estimates using ASAP:", file_conn)
  writeLines(capture.output(print(Diversity(asap, "abundance", q = c(0, 1, 2)))), file_conn)
  writeLines(capture.output(print(ChaoSpecies(asap, "abundance", k = 2, conf = 0.95))), file_conn)
  
  # Inspect the iNEXT object to see the estimators used
  writeLines("\n\nInspecting iNEXT object structure:", file_conn)
  writeLines(capture.output(str(family_iNEXT)), file_conn)
}

for (family in unique_family_names) {
  # Extract columns corresponding to the current family
  family_cols <- which(family_names == family) + 1 # Adding 1 to match the original data indexing
  
  # Extract SpeciesID and ASAP data for the family
  family_sp_id <- as.numeric(unlist(diptera_data[3, family_cols]))
  family_sp_id <- family_sp_id[family_sp_id > 0]
  
  family_asap <- as.numeric(unlist(diptera_data[4, family_cols]))
  family_asap <- family_asap[family_asap > 0]
  
  if (length(family_sp_id) == 0 | length(family_asap) == 0) {
    next # Skip this family if no valid data is found
  }
  
  # Create accumulation curves for default endpoint
  family_list <- list(SpeciesIdentifier = family_sp_id, ASAP = family_asap)
  
  # Default iNEXT analysis
  family_iNEXT <- iNEXT(family_list, q = 0, datatype = "abundance", nboot = 100, se = TRUE, conf = 0.95)
  
  # Store results
  family_results[[family]] <- list(iNEXT = family_iNEXT, sp_id = family_sp_id, asap = family_asap)
  
  # Save the plots
  plot_dir <- "plots/"
  if (!dir.exists(plot_dir)) {
    dir.create(plot_dir)
  }
  
  png(filename = paste0(plot_dir, family, "_accumulation_curve.png"))
  plot(family_iNEXT, type = 1, se = TRUE, show.legend = TRUE, col = c("plum3", "navajowhite3"), 
       main = paste("Accumulation curve for", family))
  dev.off()
  
  png(filename = paste0(plot_dir, family, "_sample_coverage.png"))
  plot(family_iNEXT, type = 2, se = TRUE, show.legend = TRUE, col = c("plum3", "navajowhite3"), 
       main = paste("Sample Coverage", family))
  dev.off()
  
  png(filename = paste0(plot_dir, family, "_species_diversity.png"))
  plot(family_iNEXT, type = 3, se = TRUE, show.legend = TRUE, col = c("plum3", "navajowhite3"), 
       main = paste("Species Diversity for", family))
  dev.off()
  
  # Write family results to the combined file
  write_family_results(family, family_sp_id, family_asap, family_iNEXT)
}

# Close the file after all families are processed
close(file_conn)

# Print the family results to verify
str(family_results)

# Extract diversity estimates at the maximum sample size for each q
extract_final_estimates <- function(iNEXT_obj, family_name) {
  est <- iNEXT_obj$iNextEst$size_based
  final_rows <- est[est$m == max(est$m), c("Order.q", "qD", "qD.LCL", "qD.UCL")]
  final_rows$Family <- family_name
  final_rows <- final_rows[, c("Family", "Order.q", "qD", "qD.LCL", "qD.UCL")]
  return(final_rows)
}

# Create a summary table from all family results
summary_table <- do.call(rbind, lapply(names(family_results), function(fam) {
  extract_final_estimates(family_results[[fam]]$iNEXT, fam)
}))

# Save to CSV for easy use in figures or tables
write.csv(summary_table, "dip_summary_diversity_estimates.csv", row.names = FALSE)

#### Hymenoptera #####

# Upload OTU data of Hymenoptera
hymenoptera_data <- read_excel("otus_v4.xlsx", sheet = "Hymenoptera")

# Extract family names from the first row, excluding the first column
family_names <- as.character(unlist(hymenoptera_data[1, -1]))

# Get unique family names
unique_family_names <- unique(family_names)

# Create a list to store results for each family
family_results <- list()

# Open the same file for writing all results (continue from previous file)
file_conn <- file("all_family_results.txt", "a")  # Append mode

for (family in unique_family_names) {
  # Extract columns corresponding to the current family
  family_cols <- which(family_names == family) + 1
  
  # Extract SpeciesID and ASAP data for the family
  family_sp_id <- as.numeric(unlist(hymenoptera_data[3, family_cols]))
  family_sp_id <- family_sp_id[family_sp_id > 0]
  
  family_asap <- as.numeric(unlist(hymenoptera_data[4, family_cols]))
  family_asap <- family_asap[family_asap > 0]
  
  if (length(family_sp_id) == 0 | length(family_asap) == 0) {
    next # Skip this family if no valid data is found
  }
  
  # Create accumulation curves for default endpoint
  family_list <- list(SpeciesIdentifier = family_sp_id, ASAP = family_asap)
  
  # Default iNEXT analysis
  family_iNEXT <- iNEXT(family_list, q = 0, datatype = "abundance", nboot = 100, se = TRUE, conf = 0.95)
  
  # Store results
  family_results[[family]] <- list(iNEXT = family_iNEXT, sp_id = family_sp_id, asap = family_asap)
  
  # Save the plots
  plot_dir <- "plots/"
  if (!dir.exists(plot_dir)) {
    dir.create(plot_dir)
  }
  
  png(filename = paste0(plot_dir, family, "_accumulation_curve.png"))
  plot(family_iNEXT, type = 1, se = TRUE, show.legend = TRUE, col = c("plum3", "navajowhite3"), 
       main = paste("Accumulation curve for", family))
  dev.off()
  
  png(filename = paste0(plot_dir, family, "_sample_coverage.png"))
  plot(family_iNEXT, type = 2, se = TRUE, show.legend = TRUE, col = c("plum3", "navajowhite3"), 
       main = paste("Sample Coverage", family))
  dev.off()
  
  png(filename = paste0(plot_dir, family, "_species_diversity.png"))
  plot(family_iNEXT, type = 3, se = TRUE, show.legend = TRUE, col = c("plum3", "navajowhite3"), 
       main = paste("Species Diversity for", family))
  dev.off()
  
  # Write family results to the combined file
  write_family_results(family, family_sp_id, family_asap, family_iNEXT)
}

# Close the file after all families are processed
close(file_conn)

# Print the family results to verify
str(family_results)












##### Setup #####
# Load libraries, install if missing
packages <- c("dplyr", "tidyr", "ggplot2", "grid", "gridExtra", "svglite")
new_packages <- packages[!(packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) install.packages(new_packages)
lapply(packages, library, character.only = TRUE)

##### Load Data #####
data <- read.csv("April_GBOLIII_numbers.csv")

##### Data Preparation #####
##### Setup #####
# Load libraries, install if missing
packages <- c("dplyr", "tidyr", "ggplot2", "grid", "gridExtra", "svglite")
new_packages <- packages[!(packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) install.packages(new_packages)
lapply(packages, library, character.only = TRUE)

##### Load Data #####
data <- read.csv("April_GBOLIII_numbers.csv")

##### Data Preparation #####

## Plot 2 data (stacked bar by Order)
# Plot 2: Stacked bar plot combined by Order with numbers on the side
plot_2 <- ggplot(data_ordered, aes(x = Order, y = Total_Value, fill = Type)) +
  geom_bar(stat = "identity", position = "stack", color = "black", linewidth = 0.5, width = 0.5) +
  scale_fill_manual(values = c("Checklist" = "white", 
                               "min_new_Germany" = "lightgrey", 
                               "Max_New_Germany" = "darkgrey"))  +
  theme_minimal() +
  labs(title = "Combined Checklist and Germany Values by Order",
       x = "Order", y = "Total Count") +
  # Move the labels to the side of the bar
  geom_text(aes(label = Total_Value), position = position_stack(vjust = 0.5), color = "black", size = 4, hjust = 0.5)  # hjust = -0.1 moves it to the left

plot_2

## Plot 4 data (estimators by Order with SE)
data_order_estimators <- data %>%
  group_by(Order) %>%
  summarize(across(c(Chao1_spID, Chao1_ASAP, ACE_spID, ACE_ASAP,
                     Chao1_spID_se, Chao1_ASAP_se, ACE_spID_se, ACE_ASAP_se), 
                   sum, na.rm = TRUE)) %>%
  pivot_longer(cols = c(Chao1_spID, Chao1_ASAP, ACE_spID, ACE_ASAP), 
               names_to = "Estimator", values_to = "Value") %>%
  mutate(
    SE = case_when(
      Estimator == "Chao1_spID" ~ Chao1_spID_se,
      Estimator == "Chao1_ASAP" ~ Chao1_ASAP_se,
      Estimator == "ACE_spID"   ~ ACE_spID_se,
      Estimator == "ACE_ASAP"   ~ ACE_ASAP_se
    ),
    Estimator = factor(Estimator, levels = c("Chao1_spID", "Chao1_ASAP", "ACE_spID", "ACE_ASAP"))
  )


# Plot 4: Combined estimator values by Order with Standard Error (s.e.) in the center
plot_4 <- ggplot(data_order_estimators, aes(x = Order, y = Value, fill = Estimator)) +
  geom_bar(stat = "identity", position = "dodge", color = "black", linewidth = 0.5) +   
  scale_fill_manual(values = c("Chao1_spID" = "#FFFFFF",  # White  
                               "Chao1_ASAP" = "#D9D9D9",  # Light gray  
                               "ACE_spID" = "#A6A6A6",    # Medium gray  
                               "ACE_ASAP" = "#4D4D4D")) + # Dark gray  
  theme_minimal() +
  labs(title = "Combined Estimator Values by Order",
       x = "Order", y = "Total Estimate") +
  # Place the values in the center of the bars
  geom_text(aes(label = round(Value, 1)), position = position_dodge(width = 0.9), vjust = 8, size = 4) + 
  # Add standard error bars (explicitly reference the SE columns for each estimator)
  geom_errorbar(aes(ymin = Value - 
                      case_when(Estimator == "Chao1_spID" ~ Chao1_spID_se,
                                Estimator == "Chao1_ASAP" ~ Chao1_ASAP_se,
                                Estimator == "ACE_spID" ~ ACE_spID_se,
                                Estimator == "ACE_ASAP" ~ ACE_ASAP_se),
                    ymax = Value + 
                      case_when(Estimator == "Chao1_spID" ~ Chao1_spID_se,
                                Estimator == "Chao1_ASAP" ~ Chao1_ASAP_se,
                                Estimator == "ACE_spID" ~ ACE_spID_se,
                                Estimator == "ACE_ASAP" ~ ACE_ASAP_se)),
                position = position_dodge(width = 0.9), 
                width = 0.25, color = "black", linewidth = 0.7)

# Display Plot 4
plot_4

##### Plot 5: Side-by-side Plot 2 + Plot 4 #####
# Arrange plot_2 and plot_4 side by side
plot_5 <- grid.arrange(plot_2, plot_4, ncol = 2)

##### Save Plots #####
ggsave("plot_2.pdf", plot_2, width = 21, height = 29.7, units = "cm")
ggsave("plot_4.pdf", plot_4, width = 21, height = 29.7, units = "cm")
ggsave("plot_5.pdf", plot_5, width = 39.7, height = 21, units = "cm")

# Save combined plot (Plot 5) as SVG
svglite("plot_5.svg", width = 21, height = 29.7, units = "cm")
grid.draw(plot_5)
dev.off()
