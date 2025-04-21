###########################################################################################################
#Richard Ian Bailey 18 April 2025 - Updating species wishlists based on GOAT and Psyche Google Sheet info##
###########################################################################################################
library(jsonlite)
library(data.table)
library(httr)
library(googlesheets4)
library(googledrive)
###########################################################################################################
# Define a function for GET requests with retry capability
get_with_retry <- function(url, ..., max_attempts = 3, base_delay = 5) {
  # Create timeout configuration
  timeout_config <- httr::config(connecttimeout = 60, timeout = 300)
  
  for (attempt in 1:max_attempts) {
    tryCatch({
      # Pass all additional arguments (...) directly to GET
      response <- httr::GET(
        url = url,
        ...,  # This allows passing add_headers() and any other parameters
        config = timeout_config
      )
      
      # If successful, return the response
      return(response)
    }, error = function(e) {
      # Error handling code remains the same
      if (attempt == max_attempts) {
        stop(paste("Failed after", max_attempts, "attempts:", e$message))
      }
      
      wait_time <- base_delay * attempt
      message(paste("Request failed, retrying in", wait_time, "seconds... (Attempt", attempt, "of", max_attempts, ")"))
      Sys.sleep(wait_time)
    })
  }
};
###########################################################################################################
# Authenticate using service account JSON passed via environment variable
gs4_auth(path = Sys.getenv("GOOGLE_SERVICE_ACCOUNT_KEY_JSON"))
# If you also use googledrive explicitly, add:
 googledrive::drive_auth(path = Sys.getenv("GOOGLE_SERVICE_ACCOUNT_KEY_JSON"))


#The following Google authentication will need to be done for a new user with their own Google account:

# Set the authentication options
#options(gargle_oauth_email = "richardianbailey@gmail.com")#ADD YOUR GMAIL ADDRESS HERE**********

# First-time setup (run once, then comment out)
# gs4_auth(email = "xxxxxxxxxx@gmail.com", cache = TRUE)#ADD GMAIL HERE, AND RUN THIS ONLY ONCE THEN HASH OUT

# Run once locally to get the location of the token
#library(googlesheets4)
#gs4_auth(email = "richardianbailey@gmail.com", cache = TRUE)

# This will show you where the token files are stored
#gargle::gargle_oauth_sitrep()

# Export the token to a file
#token <- gargle::token_fetch(email = "richardianbailey@gmail.com")
#saveRDS(token, "github_gs_token.rds")


# Export the token to a base64 string
#token <- gargle::token_fetch(email = "richardianbailey@gmail.com")
#token_file <- tempfile()
#saveRDS(token, token_file)
#token_base64 <- base64enc::base64encode(token_file)
#writeLines(token_base64, "token_for_github.txt")



###################################
###################################
#Downloading Psyche data from GOAT#
###################################
###################################
api_url="https://goat.genomehubs.org/api/v2/"
size_limit="&size=100000"                       #Increase this number if downloading a dataset with more than 100,000 records********************


################################
#psycheinp - in progress psyche#
################################
psycheinp_url <- "search?result=taxon&query=in_progress%3DPSYCHE%20AND%20long_list%3DPSYCHE%20AND%20tax_rank%28species%29&taxonomy=ncbi&includeEstimates=true&excludeMissing%5B0%5D=in_progress&excludeAncestral%5B0%5D=in_progress&fields=long_list%2Cin_progress"


#response <- GET(
#  url = paste0(api_url, psycheinp_url,size_limit,sep=""),
#  add_headers(Accept = "text/csv")
#)

# New (using the improved function):
response <- get_with_retry(
  url = paste0(api_url, psycheinp_url, size_limit, sep=""),
  add_headers(Accept = "text/csv")
)

# Get the CSV content as text
csv_content <- content(response, as = "text")
  
psycheinp <- fread(text = csv_content)

###############################################
#psycherec - received sequencing centre psyche#
###############################################
psycherec_url <- "search?result=taxon&query=sample_acquired%3DPSYCHE%20AND%20long_list%3DPSYCHE%20AND%20tax_rank%28species%29&taxonomy=ncbi&includeEstimates=true&excludeMissing%5B0%5D=sample_acquired&excludeAncestral%5B0%5D=sample_acquired&fields=long_list%2Csample_acquired"


response <- get_with_retry(#previousy GET#
  url = paste0(api_url, psycherec_url,size_limit,sep=""),
  add_headers(Accept = "text/csv")
)

# Get the CSV content as text
csv_content <- content(response, as = "text")
  
psycherec <- fread(text = csv_content)


###############################################
#psychecoll - sample collected psyche##########
###############################################
psychecoll_url <- "search?result=taxon&query=sample_collected%3DPSYCHE%20AND%20long_list%3DPSYCHE%20AND%20tax_rank%28species%29&taxonomy=ncbi&includeEstimates=true&excludeMissing%5B0%5D=sample_collected&excludeAncestral%5B0%5D=sample_collected&fields=long_list%2Csample_collected"


response <- get_with_retry(#previousy GET#
  url = paste0(api_url, psychecoll_url,size_limit,sep=""),
  add_headers(Accept = "text/csv")
)

# Get the CSV content as text
csv_content <- content(response, as = "text")
  
psychecoll <- fread(text = csv_content)


###############################################
#psycheplus - in progress psyche and others####
###############################################
psycheplus_url <- "search?result=taxon&query=length%28sample_collected%29%3E1%20AND%20sequencing_status_psyche%3E%3Dsample_collected%20AND%20bioproject%3Dnull%2C%21PRJEB71705%20AND%20ebp_metric_date%3Dnull%20AND%20assembly_level%3Dnull%2C%21chromosome%2C%21complete%20genome%20AND%20sequencing_status_psyche%3E%3Dsample_acquired%20AND%20tax_rank%28species%29&taxonomy=ncbi&includeEstimates=true&fields=sequencing_status_psyche%2Csample_collected%2Cbioproject%2Cebp_metric_date%2Cassembly_level"


response <- get_with_retry(#previousy GET#
  url = paste0(api_url, psycheplus_url,size_limit,sep=""),
  add_headers(Accept = "text/csv")
)

# Get the CSV content as text
csv_content <- content(response, as = "text")
  
psycheplus <- fread(text = csv_content)


###############################################
#ebp - in progress ebp affiliate not psyche####
###############################################
ebp_url <- "search?result=taxon&query=long_list%3DPSYCHE%20AND%20length%28long_list%29%3E1%20AND%20sequencing_status%3E%3Dsample_collected%20AND%20sequencing_status_psyche%3Dnull%20AND%20bioproject%3D%21PRJEB71705%2Cnull%20AND%20ebp_metric_date%3Dnull%20AND%20assembly_level%3Dnull%2C%21chromosome%2C%21complete%20genome%20AND%20long_list%3DPSYCHE%20AND%20tax_rank%28species%29&taxonomy=ncbi&includeEstimates=true&fields=long_list%2Csequencing_status%2Csequencing_status_psyche%2Cbioproject%2Cebp_metric_date%2Cassembly_level"


response <- get_with_retry(#previousy GET#
  url = paste0(api_url, ebp_url,size_limit,sep=""),
  add_headers(Accept = "text/csv")
)

# Get the CSV content as text
csv_content <- content(response, as = "text")

# Read directly from the text string into a data.table
ebp <- fread(text = csv_content)


###############################################
#seq - already sequenced not psyche############
###############################################
seq_url <- "search?result=taxon&query=long_list%3DPSYCHE%20AND%20ebp_metric_date%20AND%20bioproject%21%3DPRJEB71705%20AND%20long_list%3DPSYCHE%20AND%20tax_rank%28species%29&taxonomy=ncbi&includeEstimates=true&excludeMissing%5B0%5D=long_list&size=100#long_list%3DPSYCHE%20AND%20ebp_metric_date%20AND%20bioproject!%3DPRJEB71705%20AND%20long_list%3DPSYCHE%20AND%20tax_rank(species)"


response <- get_with_retry(#previousy GET#
  url = paste0(api_url, seq_url,size_limit,sep=""),
  add_headers(Accept = "text/csv")
)


# Get the CSV content as text
csv_content <- content(response, as = "text")

# Read directly from the text string into a data.table
seq <- fread(text = csv_content)



##############################################
##############################################
#Downloading Psyche Google Sheet data#########***A REGISTERED API KEY IS NEEDED TO INTERACT WITH GOOGLE SHEETS - SEE TOP OF THIS CODE FOR INSTRUCTIONS***
##############################################
##############################################

##########################################################################################################
#Download the current list of samples, which started in the 2024 season and is being continuously updated#
##########################################################################################################

# Specify the Google Sheet ID and the worksheet name
sheet_id <- "https://docs.google.com/spreadsheets/d/1cGhiZwdWqHdeZaLW9eZDhL4jWbw-pr1nKV_akA66Ha8/edit?pli=1&gid=1962198900#gid=1962198900"
worksheet_name <- "upcoming_submissions"

# Read the specific worksheet into a data.table
dat <- as.data.table(read_sheet(sheet_id, sheet = worksheet_name))#dat is the 2024 list of species sampled.

###########################################################################################################
#Read in the raw list of all species, which may change to update species being dealt with by collaborators#
###########################################################################################################

#***The list is recorded as "Outdated_raw_data" but it's the only list I have available containing all European species' names***

# Specify the Google Sheet ID and the worksheet name
sheet_id <- "https://docs.google.com/spreadsheets/d/1cGhiZwdWqHdeZaLW9eZDhL4jWbw-pr1nKV_akA66Ha8/edit?pli=1&gid=1962198900#gid=1962198900"
worksheet_name <- "Outdated_raw_data"

# Read the specific worksheet into a data.table
raw <- as.data.table(read_sheet(sheet_id, sheet = worksheet_name))

raw=raw[!is.na(genus)]

raw[,Species:=paste(genus,species,sep=" ")]#Add a column with both genus and species names for cross referencing#


raw=raw[,.(Species,family,genus,species,assembly_status_GOAT,total_specimens_collected)]

#############################
#Cross referencing with GOAT#
#############################
raw[Species%in%psycheinp$scientific_name,inprogress:="y"][is.na(inprogress),inprogress:="n"]
raw[Species%in%psycherec$scientific_name,received:="y"][is.na(received),received:="n"]
raw[Species%in%psychecoll$scientific_name,collected:="y"][is.na(collected),collected:="n"]
raw[Species%in%psycheplus$scientific_name,collectedplus:="y"][is.na(collectedplus),collectedplus:="n"]
raw[Species%in%ebp$scientific_name,collectedebp:="y"][is.na(collectedebp),collectedebp:="n"]
raw[Species%in%seq$scientific_name,sequenced:="y"][is.na(sequenced),sequenced:="n"]


##############################################################################################
#Make sure we have families in the list of 2024 onwards sampled species from the Google sheet#
##############################################################################################

setkey(raw,Species);setkey(dat,Species)
rdat=raw[dat]#looks like this causes some duplication

############################################################################################
#Identify species among upcoming_submissions for which at least 1 female has been collected#
############################################################################################

#rdat[,unique(Sex)]#Lots of entries, but I've picked out those that appear to be female!*********************************

spp_fem_coll=rdat[Sex%in%c("fe","FEMALE","female","f","Fe","+ fe","demale"),unique(Species)]#***THIS MAY NEED TO BE UPDATED IF THERE ARE ANY NEW, DIFFERENT ENTRIES REPRESENTING FEMALES***
rdat[Species%in%spp_fem_coll,female_collected_species:="y"][is.na(female_collected_species),female_collected_species:="no_female_recorded"]

genus_fem_coll=rdat[Sex%in%c("fe","FEMALE","female","f","Fe","+ fe","demale"),unique(genus)]#***THIS MAY NEED TO BE UPDATED IF THERE ARE ANY NEW, DIFFERENT ENTRIES REPRESENTING FEMALES***
rdat[genus%in%genus_fem_coll,female_collected_genus:="y"][is.na(female_collected_genus),female_collected_genus:="no_female_recorded"]

family_fem_coll=rdat[Sex%in%c("fe","FEMALE","female","f","Fe","+ fe","demale"),unique(family)]#***THIS MAY NEED TO BE UPDATED IF THERE ARE ANY NEW, DIFFERENT ENTRIES REPRESENTING FEMALES***
rdat[family%in%family_fem_coll,female_collected_family:="y"][is.na(female_collected_family),female_collected_family:="no_female_recorded"]


############################
#List of unsampled families#
############################
#raw[genus=="Brachmia"]#Brachmia infuscatella incorrectly recorded as Autostichidae, should be Gelechiidae

setkey(raw,family);setkey(rdat,family)

###
keep=rdat[!is.na(family)&More_sampling_needed=="yes"|!is.na(family)&female_collected_family=="no_female_recorded",unique(family)]

remove=rdat[!is.na(family)&female_collected_family=="y"|!is.na(family)&More_sampling_needed=="no",unique(family)]
remove2=raw[inprogress=="y" | received=="y" | collected=="y" | collectedplus=="y" | collectedebp=="y" | sequenced=="y",unique(family)]
remove3=raw[total_specimens_collected > 0,unique(family)]
remove4=raw[assembly_status_GOAT%in%c("Chromosome","In_progress_by_collaborators"),unique(family)]#***NOT SURE IF THIS ONE IS NECESSARY? ANY INFO HERE THAT'S NOT IN THE PSYCHE DATABASE?

removeall=unique(c(remove,remove2,remove3,remove4))

keeprem=raw[family%in%keep&!family%in%removeall,unique(family)]

###
wishlist_family=
 unique(
  raw[!family==""&!family%in%removeall,
   .(family)])#

wishlist_family[family%in%keeprem,notes:="Family sampled but no female recorded; add 'no' to column 'More_sampling_needed' or record the 'Sex' as 'female' in upcoming_submissions sheet to remove from wishlist"]



##########################
#List of unsampled genera#
##########################
setkey(raw,genus);setkey(rdat,genus)

###
keep=rdat[!is.na(genus)&More_sampling_needed=="yes"|!is.na(genus)&female_collected_genus=="no_female_recorded",unique(genus)]

remove=rdat[!is.na(genus)&female_collected_genus=="y"|!is.na(genus)&More_sampling_needed=="no",unique(genus)]
remove2=raw[inprogress=="y" | received=="y" | collected=="y" | collectedplus=="y" | collectedebp=="y" | sequenced=="y",unique(genus)]
remove3=raw[total_specimens_collected > 0,unique(genus)]
remove4=raw[assembly_status_GOAT%in%c("Chromosome","In_progress_by_collaborators"),unique(genus)]

removeall=unique(c(remove,remove2,remove3,remove4))

keeprem=raw[genus%in%keep&!genus%in%removeall,unique(genus)]

###
wishlist_genus=
 unique(
  raw[!genus==""&!genus%in%removeall,
   .(genus)])#

wishlist_genus[genus%in%keeprem,notes:="Genus sampled but no female recorded; add 'no' to column 'More_sampling_needed' or record the 'Sex' as 'female' in upcoming_submissions sheet to remove from wishlist"]

#wishlist_genus[!is.na(notes)]



###########################
#List of unsampled species#
###########################

#Identify unsampled genus and family too where relevant

setkey(raw,genus,species)

###
keep=rdat[!is.na(Species)&More_sampling_needed=="yes"|!is.na(Species)&female_collected_species=="no_female_recorded",unique(Species)]

remove=rdat[!is.na(Species)&female_collected_species=="y"|!is.na(Species)&More_sampling_needed=="no",unique(Species)]
remove2=raw[inprogress=="y" | received=="y" | collected=="y" | collectedplus=="y" | collectedebp=="y" | sequenced=="y",unique(Species)]
remove3=raw[total_specimens_collected > 0,unique(Species)]
remove4=raw[assembly_status_GOAT%in%c("Chromosome","In_progress_by_collaborators"),unique(Species)]

removeall=unique(c(remove,remove2,remove3,remove4))

keeprem=raw[Species%in%keep&!Species%in%removeall,unique(Species)]


wishlist_species=
 unique(
  raw[!Species==""&!Species%in%removeall,
   .(Species,family,genus)])#

wishlist_species[Species%in%keeprem,notes:="Species sampled but no female recorded; add 'no' to column 'More_sampling_needed' or record the 'Sex' as 'female' in upcoming_submissions sheet to remove from wishlist"]

#wishlist_species[!is.na(notes)]

#Add family and genus wishlist info

wishfam=wishlist_family$family
wishgen=wishlist_genus$genus

wishlist_species[family%in%wishfam,wishlist_family:="yes"]
wishlist_species[genus%in%wishgen,wishlist_genus:="yes"]


##########################
#Upload to Google Sheet###
##########################

#family

# Specify the Google Sheet ID and the worksheet name
sheet_id <- "https://docs.google.com/spreadsheets/d/1cGhiZwdWqHdeZaLW9eZDhL4jWbw-pr1nKV_akA66Ha8/edit?pli=1&gid=1497059317#gid=1497059317"
worksheet_name <- "wishlist_family"


# Upload the data.table to the specified worksheet
sheet_write(wishlist_family, ss = sheet_id, sheet = worksheet_name)#This overwrites existing entries#


#genus

# Specify the Google Sheet ID and the worksheet name
sheet_id <- "https://docs.google.com/spreadsheets/d/1cGhiZwdWqHdeZaLW9eZDhL4jWbw-pr1nKV_akA66Ha8/edit?pli=1&gid=1497059317#gid=1497059317"
worksheet_name <- "wishlist_genus"


# Upload the data.table to the specified worksheet
sheet_write(wishlist_genus, ss = sheet_id, sheet = worksheet_name)


#species

# Specify the Google Sheet ID and the worksheet name
sheet_id <- "https://docs.google.com/spreadsheets/d/1cGhiZwdWqHdeZaLW9eZDhL4jWbw-pr1nKV_akA66Ha8/edit?pli=1&gid=1497059317#gid=1497059317"
worksheet_name <- "wishlist_species"


# Upload the data.table to the specified worksheet
sheet_write(wishlist_species, ss = sheet_id, sheet = worksheet_name)
