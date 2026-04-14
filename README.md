# S4HDD

**Statistics for High Dimensional Data – Course Project**

# Spatio-Temporal Air Pollution Modeling Pipeline

This repository contains MATLAB scripts for data preprocessing, exploratory analysis, and model estimation in a spatio-temporal framework for NO₂ and CO concentration modeling.

## Abstract

This study investigates the spatio-temporal dynamics of NO₂ and CO concentrations in the Beijing area using D-STEM software. After exploratory data analysis and feature engineering, a Hidden Dynamic Geostatistical Model (HDGM) was employed to capture spatial and temporal dependencies.

Model validation was performed using a Leave-One-Gauge-Out Cross-Validation (LOGOCV) procedure, where each monitoring station was iteratively excluded from the training set and its observations predicted. Model performance was evaluated using standard metrics and residual analysis.

---

## Project Structure

### `Dataset_enrichment.m`

This script:

* Merges individual station datasets into a single file (`combinedData.mat`)
* Creates derived variables (feature engineering)
* Handles missing values and performs data cleaning

**Output:** a unified dataset used in all subsequent analyses.

---

### `eda.m`

Contains all scripts used for exploratory data analysis.

---

### `Linear_M1.m`

Implements the baseline linear regression model (M1) with LOGOCV validation for both NO₂ and CO.

---

### `PreProcessM2.m` / `PreProcessM3.m`

These scripts:

* Perform preprocessing for the univariate HDGM models
* Prepare inputs required before running `Logocv.m` for models M2 and M3

---

### `Logocv.m`

Performs estimation of the univariate HDGM model with LOGOCV validation.

---

### `PreProcessM4.m`

Prepares the dataset for the bivariate HDGM model.

---

### `Logocv_bivariate.m`

Implements estimation of the bivariate HDGM model with LOGOCV validation.


