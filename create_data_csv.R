#-------------------------------------------
# Script by Lieke de Boer, July 2021
# Takes the digital skills workshops excel sheet and creates a datafile for the corresponding GH repo. Initially saves this locally.
# Checks if a workshop is ready to be uploaded (based on "yes" in ready column) and if so
# creates a Microsoft Teams channel with the same name as a workshop's slug,
# posts a message in the Microsoft Teams channel tagging instructors and helpers.
# Creates planning, communication and debriefing documents (.docx) from Rmd templates.
# ------------------------------------------
# To Do:
# - make sure that template documents are also uploaded (debriefing, communication, planning)
# - investigate possibility for automatic PR based on "ready"
#-------------------------------------------


library(traininginfrastructure)

ds_xlsx <- read_from_drive() # download Holy Excel Sheet
dat_struct <- get_future_workshops(ds_xlsx) # Select right information from Holy Excel Sheet

### Create folder per workshop that contains data.csv for the github page
#TODO, should this be in a different spot?
#TODO this should be a function that can easily be re-run to update info
#TODO include upload to sharepoint
#TODO suppress warnings (or make them cleaner :))
traininginfrastructure::save_viable_data(dat_struct) #only saves a data file in its folder if the slug is longer than 10 characters

### Select workshops that are ready
ready_future <- na.omit(dat_struct$slug[dat_struct$ready=="yes"])


instr_team <- Microsoft365R::get_team("Instructors")


for (i in 1:length(ready_future)) { # pick a workshop
  # Get the slug
  slug <- ready_future[i]
  # get the data for this workshop
  ws_dat <- dat_struct[which(dat_struct$slug==slug),]

  meta_fld <- get_meta_fld(slug)

  instr_team$create_channel(slug)

  ws_dat$newch <- instr_team$get_channel(slug)$get_folder()$properties$webUrl #sharepoint URL
  create_files(ws_dat, meta_fld)

  if (drv$get_item(paste0(slug, "/", slug, "-communication_doc.docx"))$type!="drive item") {
    drv$upload_file(src = paste0("files/", slug, "/", slug, "-communication_doc.docx"),
                    dest = paste0(slug, "/", slug, "-communication_doc.docx"))
  }

  if (drv$get_item(paste0(slug, "/", slug, "-planning_doc.docx"))$type!="drive item") {
    drv$upload_file(src = paste0("files/", slug, "/", slug, "-planning_doc.docx"),
                    dest = paste0(slug, "/", slug, "-planning_doc.docx"))
  }

  if (drv$get_item(paste0(slug, "/", slug, "-debriefing_doc.docx"))$type!="drive item") {
    drv$upload_file(src = paste0("files/", slug, "/", slug, "-debriefing_doc.docx"),
                    dest = paste0(slug, "/", slug, "-debriefing_doc.docx"))
  }
  traininginfrastructure::save_post_sharepoint(ws_dat)
}
#instr_team$create_channel(slug))


