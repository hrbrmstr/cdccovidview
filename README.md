
[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![Signed
by](https://img.shields.io/badge/Keybase-Verified-brightgreen.svg)](https://keybase.io/hrbrmstr)
![Signed commit
%](https://img.shields.io/badge/Signed_Commits-100%25-lightgrey.svg)
[![Linux build
Status](https://travis-ci.org/hrbrmstr/cdccovidview.svg?branch=master)](https://travis-ci.org/hrbrmstr/cdccovidview)  
![Minimal R
Version](https://img.shields.io/badge/R%3E%3D-3.2.0-blue.svg)
![License](https://img.shields.io/badge/License-MIT-blue.svg)

# cdccovidview

Weekly Surveillance Summary of U.S. COVID-19 Activity

## Description

The U.S. Centers for Disease Control provides weekly summary and
interpretation of key indicators that have been adapted to track the
COVID-19 pandemic in the United States. Tools are provided to retrive
data from both COVIDView
(<https://www.cdc.gov/coronavirus/2019-ncov/covid-data/covidview/index.html>)
and COVID-NET (<https://gis.cdc.gov/grasp/COVIDNet/COVID19_3.html>).

## What’s Inside The Tin

The following functions are implemented:

  - `about`: Display information about the data source
  - `age_groups`: Return age groups used in the surveillance
  - `available_seasons`: Show available seasons
  - `has_bom`: Tests whether a raw httr response or character vector has
    a byte order mark (BOM)
  - `laboratory_confirmed_hospitalizations`: Retrieve
    Laboratory-Confirmed COVID-19-Associated Hospitalizations
  - `mmwr_week_to_date`: Convert an MMWR year+week or year+week+day to a
    Date object
  - `mmwr_week`: Convert a Date to an MMWR day+week+year
  - `mmwr_weekday`: Convert a Date to an MMWR weekday
  - `mmwrid_map`: MMWR ID to Calendar Mappings
  - `sans_bom`: Remove byte order mark (BOM) from httr::response object
    or character vector
  - `surveillance_areas`: Show network & network catchments

## Installation

``` r
remotes::install_git("https://git.rud.is/hrbrmstr/cdccovidview.git")
# or
remotes::install_git("https://git.sr.ht/~hrbrmstr/cdccovidview")
# or
remotes::install_gitlab("hrbrmstr/cdccovidview")
# or
remotes::install_bitbucket("hrbrmstr/cdccovidview")
```

NOTE: To use the ‘remotes’ install options you will need to have the
[{remotes} package](https://github.com/r-lib/remotes) installed.

## Usage

``` r
library(cdccovidview)

# current version
packageVersion("cdccovidview")
## [1] '0.1.0'
```

``` r
library(cdccovidview)
library(hrbrthemes)
library(tidyverse)

hosp <- laboratory_confirmed_hospitalizations()

c(
  "0-4 yr", "5-17 yr", "18-49 yr", "50-64 yr", "65+ yr", "65-74 yr", "75-84 yr", "85+"
) -> age_f

mutate(hosp, start = mmwr_week_to_date(mmwr_year, mmwr_week)) %>% 
  filter(!is.na(weekly_rate)) %>% 
  filter(catchment == "Entire Network") %>% 
  select(start, network, age_category, weekly_rate) %>%  
  filter(age_category != "Overall") %>% 
  mutate(age_category = factor(age_category, levels = age_f)) %>% 
  ggplot() +
  geom_line(
    aes(start, weekly_rate)
  ) +
  scale_x_date(
    date_breaks = "2 weeks", date_labels = "%b\n%d"
  ) +
  facet_grid(network~age_category) +
  labs(
    x = NULL, y = "Rates per 100,000 pop",
    title = "COVID-NET Weekly Rates by Network and Age Group",
    caption = sprintf("Source: COVID-NET: COVID-19-Associated Hospitalization Surveillance Network, Centers for Disease Control and Prevention.\n<https://gis.cdc.gov/grasp/COVIDNet/COVID19_3.html>; Accessed on %s", Sys.Date())
  ) +
  theme_ipsum_es(grid="XY")
```

<img src="man/figures/README-ex-01-1.png" width="960" />

## cdccovidview Metrics

| Lang | \# Files |  (%) | LoC |  (%) | Blank lines |  (%) | \# Lines |  (%) |
| :--- | -------: | ---: | --: | ---: | ----------: | ---: | -------: | ---: |
| R    |       11 | 0.92 | 200 | 0.85 |          75 | 0.79 |      136 | 0.82 |
| Rmd  |        1 | 0.08 |  35 | 0.15 |          20 | 0.21 |       30 | 0.18 |

## Code of Conduct

Please note that this project is released with a Contributor Code of
Conduct. By participating in this project you agree to abide by its
terms.
