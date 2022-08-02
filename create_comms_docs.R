#-------------------------------------------
# Script by Lieke de Boer, March 2022
# Takes the digital skills workshops excel sheet and creates a communication document.
#
# Creates a Microsoft Teams channel with the same name as a workshop's slug,
# Creates communication document (.docx) from Rmd template.
# ------------------------------------------
#-------------------------------------------

library(traininginfrastructure)
library(Microsoft365R)
library(tidyverse)
library(rio)
library(nominatim)

exec_dir <- dirname(rstudioapi::getSourceEditorContext()$path) #the dir this script is in
setwd(exec_dir)

tokens     <- read.delim("tokens.txt", header=F)
token      <- stringr::str_split(tokens$V1, pattern=" ")[[1]][2]

instr_site <- get_sharepoint_site(site_url="https://nlesc.sharepoint.com/sites/instructors")
drv        <- instr_site$get_drive()
ds_xlsx    <- drv$download_file("General/Digital Skills Workshops 2022.xlsx", overwrite = T) #get the latest version of the excel sheet and overwrite the previous download
ds_xlsx    <- import("Digital Skills Workshops 2022.xlsx") #TODO: save using a portable filename. Consider adding to .gitignore
ds_xlsx    <- ds_xlsx[ds_xlsx$startdate >= Sys.time(), ] # only read workshop dates after today
dat_struct <- get_future_workshops(ds_xlsx) # extracts relevant information for GH page from spreadsheet

#dat_struct <- na.omit(dat_struct$slug)
ready_for_comms  <- dat_struct[!is.na(dat_struct$slug), ]

instr_team <- get_team("Instructors")

for (i in 1:length(ready_for_comms)) {

  slug <- ready_for_comms$slug[i]
  comms_doc_info <- ready_for_comms[(ready_for_comms$slug==slug),]
  meta_fld <- get_meta_fld(slug)

  dir.create(paste0(exec_dir,"/files/", slug))
  fill_comms_doc(comms_doc_info, meta_fld)

}



