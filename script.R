##### GBOL Supplementary Analysis Script #####
# This script processes OTU and estimator data for Diptera and Hymenoptera
# using diversity estimation tools like iNEXT, SpadeR, and vegan.
# Author: [Your Name]
# Publication: [Journal/Title]

##### Load Required Packages #####
packages <- c("readxl", "SpadeR", "vegan", "iNEXT", "readr", 
              "dplyr", "tidyr", "ggplot2", "grid", "gridExtra", "svglite")
new_packages <- packages[!(packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) install.packages(new_packages)
lapply(packages, library, character.only = TRUE)

##### Set Paths #####
data_path <- "data"
plot_path <- "plots"
if (!dir.exists(plot_path)) dir.create(plot_path)

##### Utility Function to Write Family Results #####
write_family_results <- function(file_conn, family, sp_id, asap, family_iNEXT) {
  writeLines(paste("Results for family:", family), file_conn)
  writeLines("\nSpecies Identifier Data:", file_conn)
  writeLines(paste(sp_id, collapse = ", "), file_conn)
  writeLines("\nASAP Data:", file_conn)
  writeLines(paste(asap, collapse = ", "), file_conn)

  writeLines("\n\nEstimates from iNEXT:", file_conn)
  for (datatype in names(family_iNEXT$iNextEst)) {
    writeLines(paste("\nModel:", datatype), file_conn)
    writeLines(capture.output(print(family_iNEXT$iNextEst[[datatype]])), file_conn)
  }

  writeLines("\n\nChao1 Estimates using SpeciesIdentifier:", file_conn)
  writeLines(capture.output(print(Diversity(sp_id, "abundance", q = c(0, 1, 2)))), file_conn)
  writeLines(capture.output(print(ChaoSpecies(sp_id, "abundance", k = 2, conf = 0.95))), file_conn)

  writeLines("\n\nChao1 Estimates using ASAP:", file_conn)
  writeLines(capture.output(print(Diversity(asap, "abundance", q = c(0, 1, 2)))), file_conn)
  writeLines(capture.output(print(ChaoSpecies(asap, "abundance", k = 2, conf = 0.95))), file_conn)
}

##### Function to Process a Taxonomic Group #####
process_group <- function(sheet_name, file_conn_path) {
  otu_data <- read_excel(file.path(data_path, "GBOL_OTUs.xlsx"), sheet = sheet_name)
  family_names <- as.character(unlist(otu_data[1, -1]))
  unique_family_names <- unique(family_names)
  family_results <- list()
  file_conn <- file(file_conn_path, ifelse(sheet_name == "Diptera", "w", "a"))

  for (family in unique_family_names) {
    family_cols <- which(family_names == family) + 1
    family_sp_id <- as.numeric(unlist(otu_data[3, family_cols]))
    family_sp_id <- family_sp_id[family_sp_id > 0]
    family_asap <- as.numeric(unlist(otu_data[4, family_cols]))
    family_asap <- family_asap[family_asap > 0]

    if (length(family_sp_id) == 0 | length(family_asap) == 0) next

    family_list <- list(SpeciesIdentifier = family_sp_id, ASAP = family_asap)
    family_iNEXT <- iNEXT(family_list, q = 0, datatype = "abundance", nboot = 100, se = TRUE, conf = 0.95)
    family_results[[family]] <- list(iNEXT = family_iNEXT, sp_id = family_sp_id, asap = family_asap)

    png(filename = file.path(plot_path, paste0(family, "_accumulation_curve.png")))
    plot(family_iNEXT, type = 1, se = TRUE, show.legend = TRUE, main = paste("Accumulation curve for", family))
    dev.off()

    png(filename = file.path(plot_path, paste0(family, "_sample_coverage.png")))
    plot(family_iNEXT, type = 2, se = TRUE, show.legend = TRUE, main = paste("Sample Coverage", family))
    dev.off()

    png(filename = file.path(plot_path, paste0(family, "_species_diversity.png")))
    plot(family_iNEXT, type = 3, se = TRUE, show.legend = TRUE, main = paste("Species Diversity for", family))
    dev.off()

    write_family_results(file_conn, family, family_sp_id, family_asap, family_iNEXT)
  }
  close(file_conn)
  return(family_results)
}

##### Run Analyses for Diptera and Hymenoptera #####
diptera_results <- process_group("Diptera", "all_family_results.txt")
hymenoptera_results <- process_group("Hymenoptera", "all_family_results.txt")

##### Summarize Final Diversity Estimates #####
extract_final_estimates <- function(iNEXT_obj, family_name) {
  est <- iNEXT_obj$iNextEst$size_based
  final_rows <- est[est$m == max(est$m), c("Order.q", "qD", "qD.LCL", "qD.UCL")]
  final_rows$Family <- family_name
  return(final_rows[, c("Family", "Order.q", "qD", "qD.LCL", "qD.UCL")])
}
summary_table <- do.call(rbind, lapply(names(diptera_results), function(fam) {
  extract_final_estimates(diptera_results[[fam]]$iNEXT, fam)
}))
write.csv(summary_table, "dip_summary_diversity_estimates.csv", row.names = FALSE)

##### Plot Estimator Summaries #####
data <- read.csv(file.path(data_path, "GBOL_estimators.csv"))

plot_2 <- ggplot(data, aes(x = Order, y = Total_Value, fill = Type)) +
  geom_bar(stat = "identity", position = "stack", color = "black") +
  scale_fill_manual(values = c("Checklist" = "white", 
                               "min_new_Germany" = "lightgrey", 
                               "Max_New_Germany" = "darkgrey")) +
  theme_minimal() +
  labs(title = "Combined Checklist and Germany Values by Order", x = "Order", y = "Total Count") +
  geom_text(aes(label = Total_Value), position = position_stack(vjust = 0.5), size = 4)

data_order_estimators <- data %>%
  group_by(Order) %>%
  summarize(across(contains("Chao1") | contains("ACE"), sum, na.rm = TRUE)) %>%
  pivot_longer(cols = c(Chao1_spID, Chao1_ASAP, ACE_spID, ACE_ASAP), 
               names_to = "Estimator", values_to = "Value") %>%
  mutate(
    SE = case_when(
      Estimator == "Chao1_spID" ~ Chao1_spID_se,
      Estimator == "Chao1_ASAP" ~ Chao1_ASAP_se,
      Estimator == "ACE_spID" ~ ACE_spID_se,
      Estimator == "ACE_ASAP" ~ ACE_ASAP_se
    )
  )

plot_4 <- ggplot(data_order_estimators, aes(x = Order, y = Value, fill = Estimator)) +
  geom_bar(stat = "identity", position = "dodge", color = "black") +
  scale_fill_manual(values = c("Chao1_spID" = "#FFFFFF", "Chao1_ASAP" = "#D9D9D9", 
                               "ACE_spID" = "#A6A6A6", "ACE_ASAP" = "#4D4D4D")) +
  theme_minimal() +
  labs(title = "Combined Estimator Values by Order", x = "Order", y = "Total Estimate") +
  geom_text(aes(label = round(Value, 1)), position = position_dodge(width = 0.9), vjust = 8, size = 4) +
  geom_errorbar(aes(ymin = Value - SE, ymax = Value + SE), 
                position = position_dodge(width = 0.9), width = 0.25, color = "black")

plot_5 <- grid.arrange(plot_2, plot_4, ncol = 2)

ggsave("plot_2.pdf", plot_2, width = 21, height = 29.7, units = "cm")
ggsave("plot_4.pdf", plot_4, width = 21, height = 29.7, units = "cm")
ggsave("plot_5.pdf", plot_5, width = 39.7, height = 21, units = "cm")

svglite("plot_5.svg", width = 21, height = 29.7, units = "cm")
grid.draw(plot_5)
dev.off()
