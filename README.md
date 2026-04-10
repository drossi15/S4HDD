## S4HDD
Statistics for High Dimensional Data Course Project

## Spatio-Temporal Air Pollution Modeling Pipeline

This repository contains the MATLAB scripts used for data preprocessing, exploratory analysis, and model estimation for spatio-temporal modeling of NO$_2$ and CO concentrations.

---

##  Project Structure

### 🔹 Data preprocessing and enrichment

#### `Dataset_enrichment.m`
This script is responsible for:
- merging individual station datasets into a single dataset (`combinedData.mat`)
- creating new derived variables (feature engineering)
- handling missing values and data cleaning procedures

The output is a unified dataset used in all subsequent analyses.

---

### 🔹 Exploratory Data Analysis (EDA)

#### `eda.m` 

This file contains all scripts used for exploratory data analysis
---

### 🔹 Linear baseline model

#### `Linear_M1.m`
This script implements the baseline linear regression model (M1) for:
- NO$_2$
- CO

It includes:
- model estimation
- leave-one-gauge-out cross validation
- computation of performance metrics (RMSE, R², Bias)
- residual analysis

---

### 🔹 Preprocessing for univariate HDGM models

#### `PreProcessM2.m`
#### `PreProcessM3.m`

These scripts perform the required preprocessing steps for the univariate HDGM model.
They are used before model estimation for M2 and M3.

---

### 🔹 Univariate HDGM estimation

#### `Logocv.m`
This script contains:
- estimation of the univariate HDGM model
- leave-ont-gauge-out cross validation procedure

---

### 🔹 Preprocessing for bivariate HDGM model

#### `PreProcessM4.m`
This script prepares the data for the bivariate HDGM model
---

### 🔹 Bivariate HDGM estimation

#### `Loogocv_bivariate.m`
This version of the script implements:

- estimation of the bivariate HDGM model
- leave-one-gauge-out-cross-validation

---


## Models Included

- M1: Linear regression baseline
- M2: HDGM with spatial covariates
- M3: HDGM with spatio-temporal + meteorological covariates
- M4: Bivariate HDGM (joint NO$_2$ and CO modeling)

---

