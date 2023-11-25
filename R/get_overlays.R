#Get full list of addresses in Victoria


library(sf) # simple features packages for handling vector GIS data
library(httr) # generic webservice package
library(tidyverse) # a suite of packages for data wrangling, transformation, plotting, ...
library(arcpullr)
library(strayr)
library(leaflet)

vicmap_property_rest_api_url <- 'https://enterprise.mapshare.vic.gov.au/server/rest/services/Hosted/Vicmap_Property_Address/FeatureServer/0'
vicmap_overlay_rest_api_url <- 'https://services6.arcgis.com/GB33F62SbDxJjwEL/ArcGIS/rest/services/Vicmap_Planning/FeatureServer/2'

lgas_map <- strayr::read_absmap("LGA2021") %>% 
  filter(state_name_2021 == "Victoria",
         !(lga_name_2021 %in% c("Unincorporated Vic",
                              "No usual address (Vic.)",
                              "Migratory - Offshore - Shipping (Vic.)"))) %>% 
  st_transform("EPSG:7899")


get_overlays_for_council <- function(council_name) {
  print(paste('running for',council_name))
  
heritage_overlays <- get_layer_by_poly(vicmap_overlay_rest_api_url,
                                       where = "SCHEME_CODE = 'HO'",
                                       geometry = lgas_map %>% 
                                                  filter(lga_name_2021 == council_name)) %>% 
  st_make_valid()

print(paste(nrow(heritage_overlays),'hertiage overlays obtained'))
useful_columns <- c("add_ezi_address",
                    "prop_pfi",
                    "propv_base_pfi",
                    "add_is_primary")

get_properties_inside_overlay <- function() {arcpullr::get_layer_by_poly(vicmap_property_rest_api_url,
                                                    geometry = heritage_overlays,
                                                    out_fields = useful_columns,
                                                    where = "propv_base_pfi IS NULL") }

#Sometimes the API returns an error, if this happens just try again. 
repeat {
  properties_inside_ho<-try(get_properties_inside_overlay())
  if (!(inherits(properties_inside_ho,"try-error"))) 
    break
}

print(paste(nrow(properties_inside_ho),'properties inside overlay'))

return(properties_inside_ho)
      
}

output <- map_dfr(lgas_map$lga_name_2021,get_overlays_for_council)


source("R/import_filtered_heritage_db.R")
heritage_db <- import_filtered_heritage_db()


properties_in_overlay_by_type <- output %>% 
                                 st_join(heritage_db) %>% 
  mutate(order_of_status = case_when(status == "Victorian Heritage Register" ~ 1,
                                     status == "Overlay - Significant" ~ 2,
                                     status == "Overlay - Contributory"  ~3,              
                                     status == "Overlay - Not Signficant"  ~4,            
                                     status == "Overlay - Type of Listing Not Recorded" ~ 5,
                                     T ~ 6)) %>% 
  arrange(order_of_status) %>% 
  distinct(prop_pfi,.keep_all = T)

properties_in_overlay_by_type %>% write_rds("overlay_by_type.rds")

properties_in_overlay_by_type %>% 
  group_by(status) %>% 
  st_drop_geometry() %>% 
  summarise(n=n()) 

#For NAs, let's try again with a lat lon buffer.... 

properties_by_type_with_buffer <- 
  properties_in_overlay_by_type %>% 
  filter(is.na(status)) %>% 
  dplyr::select(-status,
                -id,
                -heritage_authority_name,
                -order_of_status) %>%
  st_buffer(dist = .00005) %>% 
  st_join(heritage_db) %>% 
  bind_rows(properties_in_overlay_by_type %>% filter(!is.na(status))) %>% 
  arrange(order_of_status) %>% 
  distinct(prop_pfi,.keep_all = T)

properties_by_type_with_buffer %>% 
  group_by(status) %>% 
  st_drop_geometry() %>% 
  summarise(n=n())

properties_by_type_with_buffer %>% 
  mutate(status = if_else(is.na(status),"Overlay - Not in the Database",status)) %>%
  write_rds("heritage_overlay_properties_with_heritage_db.rds")


