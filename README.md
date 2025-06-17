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
Place your data files (GBOL_OTUs.xlsx and GBOL_estimators.csv) into the data/ directory.
Open script.R in RStudio or your R environment.
Run the script to generate output plots and summary statistics.
Output will be saved in the plots/ folder and a CSV with diversity estimates.
Dependencies
The script automatically installs and loads the following R packages:

readxl, SpadeR, vegan, iNEXT, readr
dplyr, tidyr, ggplot2, grid, gridExtra, svglite
Make sure you have internet access for package installation.

Citation
If using this script, please cite the associated publication:

Awad et al. Fresh eyes on biodiversity discover a thousand and more species new to Germany
