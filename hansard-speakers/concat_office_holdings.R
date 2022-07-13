library(tidyverse)

dir <- "/home/stephbuon/Downloads/offices/"

office_holdings <- read_csv(paste0("/home/stephbuon/Downloads/officeholdings.csv")) %>%
                              select(member_id, office_id, start_date, end_date) %>%
                              rename(corresponding_id = member_id,
                                     start = start_date,
                                     end = end_date)


office_holdings$corresponding_id <- as.character(office_holdings$corresponding_id)
office_holdings$start <- as.character(office_holdings$start)
office_holdings$end <- as.character(office_holdings$end)

# offices <- read_csv(paste0(dir, "prime_minister.csv")) %>%
#   select(-alias)

files <- list.files(path = dir, pattern = "*.csv")

out <- data.frame()

for(file in files) {
  
  print(file)
  
  temp <- read_csv(paste0(dir, file)) %>%
    select(office_id, corresponding_id, real_name, start, end)
  
  temp$start <- as.character(temp$start)
  temp$end <- as.character(temp$end)
  temp$corresponding_id <- as.character(temp$corresponding_id)
  
  out <- bind_rows(out, temp) }


a <- bind_rows(office_holdings, out)


a <- a %>%
  distinct()

write_csv(a, "~/office-holdings.csv")
