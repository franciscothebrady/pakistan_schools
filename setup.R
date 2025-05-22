## setup file
# OOO:
# 1. download packages if not already installed
# 2. set up file paths

# call packages; install if not
required_pkgs <- c("ggplot2", "dplyr", "data.table", 
                   "stringr", "glue", "here", "readr",
                   "janitor")
not_installed <- required_pkgs[!(required_pkgs %in% installed.packages()[,"Package"])]
if(length(not_installed)) {
  for (pkg in not_installed) {
    print(glue("Installing {pkg}..."))
    install.packages(pkg)
  }
}

# set up file paths 
# potentially set up dropbox access here as well for data 
library(here)
library(glue)

# here::here()
# TODO: change to dropbox
raw_data <- "/home/francisco/project774/data/raw/"
processed_data <- "/data/processed/"
figures <- glue(here::here(), "/output/figures/")
tables <- glue(here::here(), "/output/tables/")
