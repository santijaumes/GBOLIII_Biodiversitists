GBOL Supplementary Material

**Repository Structure**

GBOL_Supplementary/
├── data/
│   ├── otus_v4.xlsx
│   ├── April_GBOLIII_numbers.csv
├── plots/
├── script.R
├── README.md

**Instructions**

Place your data files (otus_v4.xlsx and April_GBOLIII_numbers.csv) into the data/ directory.
If your repository includes differently named files (e.g. GBOL_OTUs.xlsx or GBOL_estimators.csv), rename them or update the file paths in the script accordingly.
Open script.R in RStudio (version ≥ 1.4, latest version recommended) or any R environment (version ≥ 4.0.0).
Run the script to generate output plots and summary statistics.
Output will be saved in the plots/ folder and as CSV and text files in the main directory.
Expected runtime: approximately 10–15 minutes on a standard desktop computer (Intel i5, 8 GB RAM, Windows 11).
Please make sure you have internet access for automatic package installation.
To run the script on your own data, structure your input files similarly to:
otus_v4.xlsx: taxa × samples matrix (Row 1 = family names; Row 3 = SpeciesIdentifier abundances; Row 4 = ASAP abundances)
April_GBOLIII_numbers.csv: order-level diversity estimators and standard errors with columns for Order, Type, Total_Value, Chao1_spID, ACE_spID, etc.
Place your data files in the data/ directory before running the script.

**Dependencies**

The script automatically installs and loads the following R packages:
readxl, SpadeR, vegan, iNEXT, readr,
dplyr, tidyr, ggplot2, grid, gridExtra, svglite
Please make sure internet access during package installation.
(Approximate installation time: ≤ 180 seconds on a standard broadband connection.)

**System Requirements**

Operating system: Windows 11 Home (tested); should also run on macOS and Linux.
R version: ≥ 4.0.0 (April 2020)
RStudio version: ≥ 1.4 (latest version tested)
Example test system: Asus VivoBook Flip 14, Intel Core i5 processor, 8 GB RAM
Hardware requirements: No non-standard hardware required.
Operating system: Windows 11 Home (tested); should also run on macOS and Linux.
R version: ≥ 4.0.0 (April 2020)
RStudio version: ≥ 1.4 (latest version tested)

**Installation Guide**

Clone or download this repository (GBOL_Supplementary.zip).
Open script.R in RStudio or R.
Run the script; missing packages will be installed automatically.
(Typical installation time: ≈ 3 minutes on a standard desktop computer.)
Example test system: Asus VivoBook Flip 14, Intel Core i5 processor, 8 GB RAM
Hardware requirements: No non-standard hardware required.

**Input and Output Files**

*Input files*

otus_v4.xlsx — Excel workbook with two sheets (“Diptera” and “Hymenoptera”) containing family-level abundance data.
Row 1: family names
Row 3: SpeciesIdentifier abundances
Row 4: ASAP abundances
April_GBOLIII_numbers.csv — CSV file containing order-level diversity estimators and standard errors used for plotting summary figures.
Required columns: Order, Type, Total_Value, Chao1_spID, Chao1_ASAP, ACE_spID, ACE_ASAP, and their standard-error columns.

*Output files*

all_family_results.txt — Combined text file summarizing iNEXT results and diversity estimates for each family (Diptera + Hymenoptera).
dip_summary_diversity_estimates.csv — Summary table of diversity estimates at the maximum sample size for Diptera (Family, Order.q, qD, qD.LCL, qD.UCL).
/plots/ — Folder containing per-family PNG plots:
*_accumulation_curve.png
*_sample_coverage.png
*_species_diversity.png
Summary figures:
plot_2.pdf, plot_4.pdf, plot_5.pdf, and plot_5.svg — combined plots summarizing checklist data and estimator comparisons across orders.

**Expected Output**

The script generates:
Diversity estimator summary tables (dip_summary_diversity_estimates.csv)
Per-family accumulation and diversity plots (saved in /plots/)
Combined summary figures (plot_2.pdf, plot_4.pdf, plot_5.pdf, plot_5.svg)
A comprehensive text summary (all_family_results.txt) suitable for inclusion as supplementary material.

**Citation**

If you use this script, please cite the associated publication:
Awad et al. Through fresh eyes — vast biodiversity discovery in the shadow of insect decline.
