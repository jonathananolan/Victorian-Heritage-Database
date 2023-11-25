library(sf)
library(tidyverse)
library(ggthemes)

heritage_properties <- read_rds("heritage_overlay_properties_with_heritage_db.rds")

lgas_map <- strayr::read_absmap("lga2022") %>% 
  filter(state_name_2021 == "Victoria",
         !(lga_name_2022 %in% c("Unincorporated Vic",
                                "No usual address (Vic.)",
                                "Migratory - Offshore - Shipping (Vic.)"))) %>% 
  st_transform(st_crs(heritage_properties)) %>% 
  dplyr::select(lga_name_2022)


heritage_properties_with_lga <- heritage_properties %>% 
  st_join(lgas_map)

heritage_properties_with_lga %>% 
  mutate(lga_name_2022 = if_else(lga_name_2022 == "Moreland","Merri-bek",lga_name_2022)) %>%
  filter(!is.na(lga_name_2022),
         status !="Victorian Heritage Register") %>%
  st_drop_geometry() %>%
  group_by(lga_name_2022,
           status) %>% 
  summarise(n=n()) %>%
  group_by(lga_name_2022) %>% 
  mutate(total = sum(n)) %>% 
  ungroup() %>% 
  filter(total >1000) %>% 
  mutate(lga_name_2022 = fct_reorder(lga_name_2022,
                                     total),
         status = fct_relevel(status,c("Overlay - Not in the Database",
                                       "Overlay - Type of Listing Not Recorded",
                                       "Overlay - Not Signficant"))) %>% 
  ggplot(aes(x = lga_name_2022, 
             y = n, 
             fill = status))+
  geom_bar(sta = "identity")+
  coord_flip()+
  labs(x = element_blank(),
       y = "Number of properties",
       fill = "Status",
       title = "Victorian Heritage Overlay Propteries\nPresent in the Heritage Database")+
  scale_y_continuous(labels = scales::number_format(big.mark = ",")) +
  theme_minimal()+
  scale_fill_manual(values = c("#A20303",
                    "#DC0404",
                    "#0EA203",
                    "#10C004",
                    "#13DC04"
                    ))+
  theme(panel.grid = element_blank())+
  theme(legend.position = "right")

ggsave("heritage_database_compliance.png",width = 8)
