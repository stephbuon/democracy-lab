library(tidyverse)
library(lubridate)

# important -- clean records

dir <- "~/"
a <- read_csv("~/stanford_congressional_records.csv")

a$date <- gsub('^(.{4})(.*)', '\\1-\\2', a$date)
a$date <- gsub('^(.{7})(.*)', '\\1-\\2', a$date)

a$date <- as.Date(a$date)

a <- a %>%
  mutate(year = year((date)))

# did first year 1872, last year 1950
# first year 1949, last year 2011

filtered <- a %>%
  filter(year > first_year) %>%
  filter(year < last_year)

write_csv(filtered, file.path(dir, paste0("stanford_congressional_records_", (first_year + 1), "_", (last_year - 1), ".csv")))






####  not working: (and my dates are off - go back)

first_year <- c(1872, 1949)
last_year <- c(1950, 2011)

for (y1 in first_year) {
  for (y2 in last_year) {
  filtered <- a %>%
    filter(year > first_year,
           year < last_year) 
    
  write_csv(filtered, file.path(dir, paste0("stanford_congressional_records_", (first_year + 1), "_", (last_year - 1), ".csv")))
    
    
  } }

funct <- function(a, first_year, last_year) {
  filtered <- a %>%
    filter(year > first_year,
           year < last_year) 
  
  return(filtered)
}

test <- apply(funct, a, first_year, last_year)



for(i in 1:10} {
  for (j in 1:10) {
    if vector[j] == vector2[i]
    print(variable)
    else 
      print(NA)
  }
}



write_csv(variable_name, file.path(dir, "data.csv"))

first_year <- "1872"
last_year <- "1950"

filtered <- a %>%
  filter(year > first_year) %>%
  filter(year < last_year)


first_year <- 1950
last_year <- 2011
