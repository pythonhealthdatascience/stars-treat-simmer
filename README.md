[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.11546973.svg)](https://doi.org/10.5281/zenodo.11546973)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Read the Docs](https://readthedocs.org/projects/pip/badge/?version=latest)](https://pythonhealthdatascience.github.io/stars-treat-simmer/)
[![ORCID: Harper](https://img.shields.io/badge/Alison_Harper-0000--0001--5274--5037-brightgreen)](https://orcid.org/0000-0001-5274-5037)
[![ORCID: Monks](https://img.shields.io/badge/Tom_Monks-0000--0003--2631--4481-brightgreen)](https://orcid.org/0000-0003-2631-4481)
[![ORCID: Heather](https://img.shields.io/badge/Amy_Heather-0000--0002--6596--3479-brightgreen)](https://orcid.org/0000-0002-6596-3479)
[![ORCID: Mustafee](https://img.shields.io/badge/Nav_Mustafee-0000--0002--2204--8924-brightgreen)](https://orcid.org/0000-0002-2204-8924)

# 💫  Towards Sharing Tools, Artifacts, and Reproducible Simulation: a `simmer` model example

> 🏗 **WORK IN PROGRESS** (STARS 2.0) 🏗️   
  > The materials in this repo are experimental. 

> 🐍 [Looking for a python implementation? ](https://github.com/pythonhealthdatascience/stars-simpy-example-docs)

## Overview

  The materials and methods in this documentation support work towards developing the **STARS healthcare framework** (**S**haring **T**ools and **A**rtifacts for **R**eproducible **S**imulations in healthcare).  Long term S.T.A.R.S aims to support researchers share open simulation models regardless of language choice, improve the quality of sharing, and reduce the workload required to meet high standards of open science for the modelling and simulation community.

> The code and written materials are a **work in progress** towards STARS version 2.0. It is not recommended to use these materials in simulation practice at the moment.
  
This repo demonstrates the application of sharing a discrete-event simulation model in R and associated research artifacts:  
  
  * All artifacts in this repository are linked to study researchers via ORCIDs;
  * Model code is made available under the MIT license;
  * Project dependencies managed through `renv`
  * The R code and simmer model are documented and explained in a quarto website served up by GitHub pages;
  * The materials are deposited and made citatable using Zenodo;
  * [**To do**: The models are sharable with other researchers and the NHS without the need to install software.]

## Author ORCIDs

[![ORCID: Harper](https://img.shields.io/badge/ORCID-0000--0001--5274--5037-brightgreen)](https://orcid.org/0000-0001-5274-5037)
[![ORCID: Monks](https://img.shields.io/badge/ORCID-0000--0003--2631--4481-brightgreen)](https://orcid.org/0000-0003-2631-4481)
[![ORCID: Heather](https://img.shields.io/badge/ORCID-0000--0002--6596--3479-brightgreen)](https://orcid.org/0000-0002-6596-3479)
[![ORCID: Mustafee](https://img.shields.io/badge/ORCID-0000--0002--2204--8924-brightgreen)](https://orcid.org/0000-0002-2204-8924)

## Citation

Please cite our code if you use it:

```
Monks, T., Harper, A., Heather, A., & Mustafee, N. (2024). Towards Sharing Tools, Artifacts, and Reproducible Simulation: a `simmer` model example (v0.2.0). Zenodo. https://doi.org/10.5281/zenodo.11222943
```

```bibtex
@software{monks_2024_11546973,
  author       = {Monks, Thomas and
                  Harper, Alison and
                  Heather, Amy and
                  Mustafee, Navonil},
  title        = {{Towards Sharing Tools, Artifacts, and Reproducible 
                   Simulation: a `simmer` model example}},
  month        = jun,
  year         = 2024,
  publisher    = {Zenodo},
  version      = {v0.3.0},
  doi          = {10.5281/zenodo.11222943},
  url          = {https://doi.org/10.5281/zenodo.11222943}
}
```


We do not have a publication to support this work yet.  For now, please cite the Journal of Simulation article that reports STARS 1.0 and our pilot work.

```bibtex
@article{towards_stars_jos_paper,
author = {Thomas Monks, Alison Harper and Navonil Mustafee},
title = {Towards sharing tools and artefacts for reusable simulations in healthcare},
journal = {Journal of Simulation},
volume = {0},
number = {0},
pages = {1--20},
year = {2024},
publisher = {Taylor \& Francis},
doi = {10.1080/17477778.2024.2347882},
URL = { https://doi.org/10.1080/17477778.2024.2347882},
}
```

## Funding

This work was supported by the Medical Research Council [grant number MR/Z503915/1]

## Case study model

**This example is based on exercise 13 from Nelson (2013) page 170.**  Please also credit this work is you use our materials.

> *Nelson. B.L. (2013). [Foundations and methods of stochastic simulation](https://www.amazon.co.uk/Foundations-Methods-Stochastic-Simulation-International/dp/1461461596/ref=sr_1_1?dchild=1&keywords=foundations+and+methods+of+stochastic+simulation&qid=1617050801&sr=8-1). Springer.* 

We adapt a textbook example from Nelson (2013): a terminating discrete-event simulation model of a U.S based treatment centre. In the model, patients arrive to the health centre between 6am and 12am following a non-stationary Poisson process. On arrival, all patients sign-in and are triaged into two classes: trauma and non-trauma. Trauma patients include impact injuries, broken bones, strains or cuts etc. Non-trauma include acute sickness, pain, and general feelings of being unwell etc. Trauma patients must first be stabilised in a trauma room. These patients then undergo treatment in a cubicle before being discharged. Non-trauma patients go through registration and examination activities. A proportion of non-trauma patients require treatment in a cubicle before being discharged. The model predicts waiting time and resource utilisation statistics for the treatment centre. The model allows managers to ask question about the physical design and layout of the treatment centre, the order in which patients are seen, the diagnostic equipment needed by patients, and the speed of treatments. For example: “what if we converted a doctors examination room into a room where nurses assess the urgency of the patients needs.”; or “what if the number of patients we treat in the afternoon doubled” 

## Instructions to run the model

> 🏗 **Only tested on Linux (Ubuntu 22.04)* 🏗️   
  > The materials in this repo are experimental. 

> We recommend the use of RStudio to run the code locally.

### Downloading the code

Either clone the repository using git or click on the green "code" button and select "Download Zip".

```bash
git clone https://github.com/pythonhealthdatascience/stars-treat-simmer
```

### Installing dependencies

The current version of the code is maintained in R version 4.4.1

Dependencies are managed via [renv](https://rstudio.github.io/renv/articles/renv.html). To replicate the R package software environment follow these instructions:

1. Open RStudio
2. Using RStudio open the project `treat-sim-rsimmer.Rproj` (


At this point RStudio will identify that `renv` is required and install and activate it.  To restore the R packages issue the following command in R:

```R
renv::restore()
```

> You may need to wait several minutes while the software environment is restored.

## Online documentation produced by Quarto

[![Read the Docs](https://readthedocs.org/projects/pip/badge/?version=latest)](https://pythonhealthdatascience.github.io/stars-treat-simmer/)

* The documentation can be access at [https://pythonhealthdatascience.github.io/stars-treat-simmer/](https://pythonhealthdatascience.github.io/stars-treat-simmer/)
