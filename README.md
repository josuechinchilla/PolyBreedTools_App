# breedTools Poly App

![Version](https://img.shields.io/badge/version-1.1-blue.svg)  
![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)  
![Status](https://img.shields.io/badge/development-active-brightgreen.svg)

**breedTools Poly App** is a Shiny application for ancestry estimation using genotypic data. Designed to support any species and ploidy level, it enables users to estimate admixture proportions using reference populations and visualizes ancestry results interactively.

---

## Overview

This app allows users to:

- Upload genotype files for **reference** and **validation** (aka test) individuals  
- Upload a file mapping **reference IDs to populations**  
- Specify **organism ploidy**  
- Perform ancestry estimation using `breedTools::RpolyBreedTools()`  
- Visualize ancestry proportions interactively for each individual  

Designed to work seamlessly with **polyploid** and **non-model** species.

---

## Dependencies

This app requires the following R packages:

- `shiny`: Build the user interface  
- `BIGr`: For breedTools methods adapted to any ploidy
- `tidyverse`: For data manipulation and plotting  
- `scales`: For pretty formatting of percentages  
- `viridis`: For color-blind friendly plots  
- `openxlsx`: For outputting ancestry matrices to Excel  

Install all dependencies with:

```r
install.packages(c("shiny", "tidyverse", "scales", "viridis", "openxlsx", "BIGr"))
# install breedTools from GitHub
remotes::install_github("Breeding-Insight/breedTools")
```

---

## Usage

To run the app locally:

```r
# Load shiny
library(shiny)

# Run the app from local directory
runApp("path/to/breedTools_Poly_App")
```

---

## Input Files

All files must be **tab-separated** and include headers.

### 1. Reference Genotype File  
- Rows: Individuals  
- Columns: Marker values (e.g., 0, 1, 2)  
- Row names: Individual IDs  

### 2. Validation Genotype File  
- Same format as reference file  
- Must contain the **same markers in the same order**

### 3. Reference ID File  
- Two columns:  
  - `ID`: Matches row names in the reference file  
  - `Population`: Reference group or population name

### 4. Ploidy  
- Select organism ploidy from the app interface (e.g., 2, 4, 6)

---

## Output

The app produces:

- An interactive **ancestry barplot** for each validation individual  
- A **downloadable Excel file** with ancestry proportions:  
  - Rows: Validation individuals  
  - Columns: Reference populations

---

## Citation

For publication, please cite:

- [Funkhouser et al.](https://academic.oup.com/tas/article/1/1/36/4636602) for original breedTools methods  
- [Sandercock et al.](https://acsess.onlinelibrary.wiley.com/doi/10.1002/tpg2.70067) for methods expansion to polyploidy  
- This app:  
Chinchilla-Vargas, Josue. 2025.
“breedTools Poly App: Shiny App for Genomic Ancestry Estimation in Any Species.” https://github.com/Breeding-Insight/breedTools_Poly_App RRID: Pending
