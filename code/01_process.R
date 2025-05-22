## process raw data 
## OOO: 
# 1. load data (currently from google drive)
# 2. rename all variables
# 3. binarize all variables that can be
# 4. save data to dropbox

# set up 
library(dplyr)
library(janitor)
library(haven)
library(readr)
# library(data.table)
library(here)

# load file paths
source(here::here("setup.R"))

# load data ----
# TODO: move data to dropbox 
frb_data <- read_dta(glue(raw_data, "/francisco.dta"))

clean_data <- frb_data %>%
  # rename all variables
  # TODO: confirm with @Salman which variables apply to LSS
  # and which apply to HSS, although I think these are mostly correct.
  select(lss_id = school_id,
         student_id = anonymized_id,
         student_eft = eft,
         student_tfey = tfey,
         lss_type = SchoolType,
         lss_typedetail = SchoolTypeExtended,
         lss_year = MatricYear,
         lss_studygroup = MatricStudyGroup,
         lss_estyear = EstablishmentYear,
         lssc_score = ObtainedMarks,
         lssc_status = Status,
         lss_gender = Gender, # TODO: which one of these is right!!!!
         lss_gender2 = School_Gender,
         hssc_score = Inter,
         hss_spec = Subj,
         hss_type = College1,
         hss_typedetail = CollegeExtended1,
         lss_district = district,
         lss_ucname = uc_name,
         lss_moza = moza,
         lss_tehsil = tehsil,
         lss_permadress = permanent_address,
         lss_markaz = markaz,
         lss_street = street_name,
         lss_urban = School_Location,
         lss_language = MediumOfInstruction,
         lss_classrooms = ClassRooms,
         lss_playground = play_ground,
         lss_water = drink_water,
         lss_electricity = electricity,
         lss_toilets = toilets,
         lss_boundarywall = boundary_wall,
         lss_lab = lab_exist,
         lss_computerlab = com_lab_evening,
         lss_area = TotalAreaKanal,
         lss_library = library,
         lss_building_status = bldg_ownship)

# drop raw data
rm(frb_data)

# clean variables ----
clean_data <- clean_data %>%
  mutate(hss_medical = as.numeric(hss_spec == "Med"),
         hss_engineering = as.numeric(hss_spec == "Eng"),
         # note: using lss_gender to create boys
         lss_boys = as.numeric(lss_gender == "Boys"),
         lss_private = as.numeric(lss_type == "Private"),
         hss_private = as.numeric(hss_type == "Private"),
         lss_urban = as.numeric(lss_urban == "Urban"),
         hss_topgov = as.numeric(hss_typedetail == "Government-Top"),
         lss_urdu = as.numeric(lss_language == "Urdu"),
         lss_playground = ifelse(lss_playground == "Yes" | lss_playground == 1, 1, 0),
         # TODO: find better figures on water -- we can't use this
         # lss_water
         lss_electricity = ifelse(lss_electricity == "Yes" | lss_electricity == 1, 1, 0),
         lss_toilets = ifelse(lss_toilets == "Yes" | lss_toilets == 1, 1, 0),
         lss_boundarywall = ifelse(lss_boundarywall == "Yes" | lss_boundarywall == 1, 1, 0),
         lss_lab = ifelse(lss_lab == "Yes" | lss_lab == 1, 1, 0),
         lss_computerlab = ifelse(lss_computerlab == "Yes" | lss_computerlab == 1, 1, 0),
         # building ownership (based on building status)
         lss_ownbuilding = as.numeric(lss_building_status == "Owned"),
         # note: this variable contains 0,1,2, No, and Yes -- assume 1/Yes is correct, else 0
         lss_library = ifelse(lss_library == "Yes" | lss_library == 1, 1, 0),
         # create treatment variable 
         transition = as.numeric(lss_urdu == 1)
  )
  
# years 
clean_data %>% tabyl(lss_year)
# drop 2013, 2020
clean_data <- clean_data %>%
  filter(lss_year != 2013 & lss_year != 2020)

# output ----
write_csv(clean_data, 
          glue(here::here(), processed_data, "01_processed_scores.csv"))
