# PolyBreedTools_App

![Version](https://img.shields.io/badge/version-1.1-blue.svg)
![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)
![Status](https://img.shields.io/badge/development-active-brightgreen.svg)


breedTools Poly App is a shiny app that simplifies mate allocation decisions for breeders.
  
## Overview
This shiny app allows breeders to combine multiple traits in a selection index and assign a relative weight to each trait. AlloMate also allows to simplify mate allocation by filtering out possible crosses with negative ebvs and by using a kinship threshold between parents set by the user.
Current version calculates kinship through pedigree information only, we are working on supporting genotypic information using an Optimal Contribution Selection (OCS) framework in the near future.

## Dependencies

This app requires the following R packages:

- **shiny**: For building the interactive web app interface  
- **DT**: For rendering interactive data tables  
- **shinyjs**: For additional Shiny JavaScript utilities  
- **readxl**: For reading Excel files (if needed)  
- **openxlsx**: For writing Excel output files  
- **dplyr**: For data manipulation  
- **tidyr**: For data tidying  
- **readr**: For reading tab-separated files  
- **purrr**: For functional programming helpers  
- **kinship2**: For pedigree and kinship calculations  
- **tibble**: For enhanced data frames  

You can install any missing packages with:

```r
install.packages(c("shiny", "DT", "shinyjs", "readxl", "openxlsx", "dplyr", "tidyr", "readr", "purrr", "kinship2", "tibble"))
## Usage

### To run the app:

```r
# Install required packages if not already installed
packages <- c("shiny", "DT", "shinyjs", "readxl", "openxlsx", "dplyr", "tidyr")
installed <- packages %in% rownames(installed.packages())
if (any(!installed)) install.packages(packages[!installed])

# Run the app from GitHub
shiny::runGitHub("Breeding-Insight/AlloMate", subdir = "app")
```
### Input files
##### Pedigree
3 column tab separated file with with headers id, sire and dam in any order.

##### Selection Candidates
2 column tab separated file with candidate ids in "id" column and M or F in "sex" column.

##### EBVs
One tab-separated file per trait, 2 columns "ID and EBV"

### Output file
Excel file with two tabs.  
First tab shows a table with all possible male and female combinations regardless of any filters applied.  
Second tab shows a matrix with females in rows and males in columns. Crosses with kinship coefficients larger than the threshold or negative EBVs will be blank.

### Caution
Before uploading, ensure that **EBVs are pre-processed**:

- **Centered and scaled**, if appropriate for your analysis  
- **Transformed to a positive scale**, so that higher values represent better individuals  

Proper preprocessing ensures that the selection index and filtering steps in the app function as intended.

## Citation

For publication, please cite:

- [Funkhouser et al.](https://academic.oup.com/tas/article/1/1/36/4636602) for original breedTools methods  
- [Sandercock et al.](https://acsess.onlinelibrary.wiley.com/doi/10.1002/tpg2.70067) for methods expansion to polyploidy  
- This app:  
Chinchilla-Vargas, Josue. 2025.
“breedTools Poly App: Shiny App for Genomic Ancestry Estimation in Any Species.” https://github.com/Breeding-Insight/breedTools_Poly_App RRID: Pending
