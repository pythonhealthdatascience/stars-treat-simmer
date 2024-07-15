# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html). Dates formatted as YYYY-MM-DD as per [ISO standard](https://www.iso.org/iso-8601-date-and-time-format.html).

Consistent identifier (represents all versions, resolves to latest): [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.10026326.svg)](https://doi.org/10.5281/zenodo.10026326)

## [v0.3.0]() - 2024-07-15
### Changes

* RENV: added new renv where dependencies are built in a fresh Ubuntu 22.04 LTS instance with R installed. 
* CHANGES: added CHANGES.md

## [v0.2.1](https://github.com/pythonhealthdatascience/stars-treat-simmer/releases/tag/v0.2.1) - 2024-07-12
### Fixed

* FIX(results analysis): patched results_replication_table chain of functions as this was relying on a global instance of exp (a list containing all parameters for the simulation experiment). This now requires a list to be passed to the function.



## [v0.2.0](https://github.com/pythonhealthdatascience/stars-treat-simmer/releases) - 2024-06-10 - [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.11546973.svg)](https://doi.org/10.5281/zenodo.11546973)

### Changed

* ANALYSIS: Added multiple_replications function
* RESULTS: refactored results section of model.qmd to produce clean replications results table and separate summary table functions.
* RESULTS: add histogram function for chosen performance measure
* LICENSE: the MIT license as no code is redistributed or modified from packages used.

### Removed

* LICENSE: package dependency image.


## [v0.1.1](https://github.com/pythonhealthdatascience/stars-treat-simmer/releases/tag/v0.1.1) - 2024-06-10 - [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.11222944.svg)](https://doi.org/10.5281/zenodo.11222944)


### Changes

* README: Added pre-release warning.


## [v0.1.0](https://github.com/pythonhealthdatascience/stars-treat-simmer/releases/tag/v0.1.0) - 2024-05-15 - 

🌱 This is the initial release of the software.

* Quarto notebooks for :
  * a `simmer` implementation the Nelson treat-sim model
  * NSPP via thinning in R
  * Limitations of common random numbers in R
* All artifacts in this repository are linked to study researchers via ORCIDs;
* Model code is made available under the MIT license;
*[To do: validate and test R dependencies managed through renv]
The R code and simmer model are documented and explained in a quarto website served up by GitHub pages;
* Docs hosted on Github pages: https://pythonhealthdatascience.github.io/stars-treat-simmer/
  


