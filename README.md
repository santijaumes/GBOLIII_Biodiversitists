GBOL Supplementary Material
This repository contains the supplementary R code and data files used for the analysis of species diversity estimators in the GBOL project.

Structure
GBOL_Supplementary/
├── data/
│   ├── GBOL_OTUs.xlsx
│   └── GBOL_estimators.csv
├── plots/
├── script.R
├── README.md

Instructions

Place the data files (otus_v4.xlsx and all_family_results.txt) into the data/ directory.
If your repository contains differently named files (e.g., data.xlsx or results.txt), rename or update the paths in the script accordingly.
Open script.R in RStudio (version ≥ 1.4) or any R environment (version ≥ 4.0.0).
Run the script to generate output plots and summary statistics.
Output will be saved in the plots/ folder and as a CSV file with diversity estimates.
Expected runtime: approximately 8–10 minutes on a standard desktop computer (AMD Ryzen 7 47000U / 16 GB RAM).

To run the script on your own data, structure your input files similarly to otus_v4.xlsx (taxa × samples matrix) and GBOL_estimators.csv (columns: estimator name, value, etc.), and place them in the data/ directory.

Dependencies

The script automatically installs and loads the following R packages:
readxl, SpadeR, vegan, iNEXT, readr,
dplyr, tidyr, ggplot2, grid, gridExtra, svglite
Please make sure internet access during installation.
(Approximate installation time: ≤ 180 seconds on a standard desktop computer.)

System Requirements

Operating System: Windows 11 Home (tested); should also run on macOS and Linux.
R version: ≥ 4.0.0 (April 2020)
RStudio version: ≥ 1.4 (or later)
Hardware: No non-standard hardware required.
Example system used: Asus VivoBook Flip 14 (Intel i5 CPU, 8 GB RAM).
No non-standard hardware is required.

Installation Guide
Clone or download this repository (GBOL_Supplementary.zip).
Open script.R in R or RStudio.
Run the script; it will install missing packages automatically.
(Typical installation time: ≈ 3 minutes on a broadband connection.)



Citation
If using this script, please cite the associated publication:

Awad et al. Through fresh eyes—vast biodiversity discovery in the shadow of insect decline
