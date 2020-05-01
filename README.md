## README (Italia-COVID-19-R)

--- 

#### I think of this repository as a *leaner* branch of [https://github.com/meredoschi/Italia-COVID-19](https://github.com/meredoschi/Italia-COVID-19).

##### Practically the same, but without the html notebook files and some other details.   

--- 

### I. Introduction

This repository contains some of my own personal, calculations, regarding the current COVID-10 epidemic in Italy.  

I do hope these notebooks (which include the ability to produce charts) and the possible insights may be useful somehow, especially if you are in a professional capacity in this veritable fight against the disease. 

*I am not an epidemiologist, just a simple mathematician.*

### II. About the project directories

#### notebooks

**Source code in R** 

- [national](notebooks/national.Rmd) 

- [provincial](notebooks/provinces.Rmd)

- [helper_functions](notebooks/helper_functions.R)

- [retrieve_protezione_civile_files](notebooks/retrieve_protezione_civile_files.Rmd)

     *Should be run at least once a day, to try and retrieve the Protezione Civile updates (i.e. two CSV files).*     

#### csv_input 

The population data comes from [ISTAT](http://dati.istat.it/Index.aspx?QueryId=18460&lang=en).  A few regional and province names were adjusted accordingly.

##### Protezione-Civile-Dataset

The COVID-19 case information is from the [Dipartimento della Protezione Civile](http://www.protezionecivile.gov.it).  

For questions or further information regarding the DPC project repository, kindly refer to: [https://github.com/pcm-dpc/COVID-19](https://github.com/pcm-dpc/COVID-19)

*In other words, I am not affiliated with ISTAT or the DPC.*   

##### Others folders/miscellaneous 

- csv_exports 

- optional_pre_processing

    *Included for completeness.* 

---

### III. Technical installation instructions 

#### *Pre-requisites*

+ The [R programming language](https://cran.rstudio.com/). 

+ [RStudio software](https://rstudio.com/products/rstudio/download/) (the free, open source 'desktop' version should work just fine).

+ [Git version control](https://git-scm.com/)

#### *Steps*

1. Choose File, New project...

 - (Create project) Version control (checkout a project from a version control repository)

 -  Git (clone a project from a git repository)

 - Repository URL: https://github.com/meredoschi/Italia-COVID-19-R 

2. Open a git or terminal window, outside any existing R projects.  

     *Or navigate to such a directory.*

   - Type: `git clone https://github.com/meredoschi/Italia-COVID-19-R`

   - Start RStudio and open the project.

--- 

### IV. About my development environment 

#### For interested scientists, doctors and other professionals.

- R language version 3.6.3 (2020-02-29)
- RStudio version 1.1.463
- Git version 2.19.1
- Operation system details:  OS X 10.11.6
  
---

**Marcelo Eduardo Redoschi**

*This page last updated: 1/5/2020*