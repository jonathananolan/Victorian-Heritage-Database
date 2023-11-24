library(tidyverse)
library(ggthemes)
heritage_db <- read_csv("heritage_db.csv") %>% 
  filter(!(heritage_authority_name %in% c("National Trust",
                                        'Victorian Heritage Inventory',
                                        'Vic. War Heritage Inventory'
                                        )),
         !(status %in% c('Not researched - evaluate later',
                               'Heritage Inventory Site',
                               'Recommended for VHI',
                               'Victorian Heritage Inventory',
                               'Recommended for VHI',
                               'Not Recommended',
                         'Demolished/Removed',
                         'Included in a Significant Landscape Overlay',
                         'Rec for other form of protection'))) %>% 
  mutate(status = case_when(status %in% c('Incl in HO area non-contributory',
                                          'Incl in HO area not sig',
                                          'Rec for HO area not sig') ~ "Overlay - Not Signficant",
                            status %in% c('Incl in HO area indiv sig',
                                          'Incl in HO area Significant',
                                          'Rec for HO area indiv sig') ~ "Overlay - Significant",
                            status %in% c('Incl in HO area contributory',
                                          'Rec for HO area contributory') ~ "Overlay - Contributory",
                            status %in% c('2003','Stage 2 study complete',
                                          'Recommended for Heritage Overlay',
                                          'Included in Heritage Overlay') ~ "Overlay - Type of Listing Not Recorded",
                            status %in% c('Recommended for VHR',
                                          'Registered') ~ "Victorian Heritage Register",
                            T~'other')) %>% 
  filter(!is.na(heritage_authority_name)) 

heritage_db %>% 
  group_by(heritage_authority_name,
           status) %>% 
  summarise(n=n()) %>%
  group_by(heritage_authority_name) %>% 
  mutate(total = sum(n)) %>% 
  ungroup() %>% 
  mutate(heritage_authority_name = fct_reorder(heritage_authority_name,
                                               total)) %>% 
  ggplot(aes(x = heritage_authority_name, 
             y = n, 
             fill = status))+
  geom_bar(sta = "identity")+
  coord_flip()+
  labs(x = element_blank(),
       y = "Number of properties",
       fill = "Status",
       title = "Victorian Heritage Database entries")+
  scale_y_continuous(labels = scales::number_format(big.mark = ",")) +
  theme_minimal()+
  theme(panel.grid = element_blank())+
  scale_fill_wsj()+
  theme(legend.position = "right")

ggsave("heritage_database_compliance.png")

