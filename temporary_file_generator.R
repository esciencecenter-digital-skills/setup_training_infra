detach("package:traininginfrastructure", unload = TRUE)
remove.packages("traininginfrastructure")
remotes::install_github(repo = "esciencecenter-digital-skills/training-infrastructure", force=T)

library(traininginfrastructure)

df <- read_from_drive() # download Holy Excel Sheet
df_struct <- get_future_workshops(df)
info <- df_struct[3,] #check info to see which row you need (that's the numer in this case. Hacky, sorry!)

debrief_doc_info <- get_debrief_doc_info(info)
plan_doc_info <- get_planning_doc_info(info)
comms_doc_info <- get_comms_doc_info(info)
render_debrief_doc(debrief_doc_info)
render_planning_doc(plan_doc_info)
render_comms_doc(comms_doc_info)
