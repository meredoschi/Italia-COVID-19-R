## README (Italia-COVID-19-R)

### I. Introduction

This repository contains some of my own personal calculations regarding the COVID-19 epidemic in Italy.  

It is more compact than the original [https://github.com/meredoschi/Italia-COVID-19](https://github.com/meredoschi/Italia-COVID-19), which included html rendered files with many charts.
It is therefore assumed that users will have the RStudio environment installed, in order to be able to generate the html files themselves.

### II. About the project directories

#### csv_input 

The population data comes from [ISTAT](http://dati.istat.it/Index.aspx?QueryId=18460&lang=en).  A few regional and province names were adjusted accordingly.

##### Protezione-Civile-Dataset

The COVID-19 case information is from the [Dipartimento della Protezione Civile](http://www.protezionecivile.gov.it).  

For questions or further information regarding the DPC project repository, kindly refer to: [https://github.com/pcm-dpc/COVID-19](https://github.com/pcm-dpc/COVID-19)

*In other words, I am not affiliated with ISTAT or the DPC.*   

#### Notebooks

- [national_2022](notebooks/national_2022.Rmd) 

   *This code was revised in part, so it should run faster than the original national notebook.*  

   The **positives remaining (percent delta)** graph is a good indication of current trends and past waves. 

- [provinces](notebooks/provinces.Rmd)

   Similarly, I watch for changes in the **provinces histogram - growth in new cases **. 

- [national](notebooks/national.Rmd) 

   *Original notebook, includes the retrospective calculations and other information not yet in the 2022 version*.

- [retrieve_protezione_civile_files](notebooks/retrieve_protezione_civile_files.Rmd)
 
   Retrieves the latest daily csv data from the *Protezione Civile*. 
   
- [helper_functions](notebooks/helper_functions.R)
   
#### Other folders (mentioned for completeness) 

##### csv_exports 

##### optional_pre_processing

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

3. Within RStudio, navigate to the notebooks directory and run:

   - [retrieve_protezione_civile_files](notebooks/retrieve_protezione_civile_files.Rmd)
   *Generally, once a day is enough.  Updates are published in the evening, Italian time.*

   - [national_2022](notebooks/national_2022.Rmd) 

   - [provinces](notebooks/provinces.Rmd)

   Optional: generate html or PDF files for the above notebooks.
   
--- 

#### Current environment information 

- R language version: 4.1.2 (2021-11-01)
- RStudio version: 1.4.1717
- Git version: 2.25.1
- Operating system: Linux 64 bits

---

**Marcelo Eduardo Redoschi**

*This page last updated: 13/3/2022*
´
