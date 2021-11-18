# EDA Indonesia Earthquakes notebook in R

# title: EDA and Visualization of Earthquake Occurrence in Indonesia over the last 20 years using R
# git: "Celestial Arcadia"

# Importing specific libraries

library(dplyr)
library(tidyr)
library(lubridate)
library(ggplot2)
library(plotly)

# Loading the dataset

df_eq1 <- read.csv("~/Dataset/Raw/EQ 2000-2004.csv")
df_eq2 <- read.csv("~/Dataset/Raw/EQ 2005-2010.csv")
df_eq3 <- read.csv("~/Dataset/Raw/EQ 2011-2015.csv")
df_eq4 <- read.csv("~/Dataset/Raw/EQ 2016-2020.csv")

# Combining the dataset

df_eq <- rbind(df_eq4,df_eq3,df_eq2,df_eq1)
df_eq

str(df_eq)

# Specified earthquake's coordinate that happened in Indonesia territory

eq_INA = df_eq %>% 
  filter(longitude>=93 & longitude<=141.25,latitude>=-15 & latitude<=9)
eq_INA

#changing the time column format

eq_INA = eq_INA %>% 
    separate(time,into = c("year","month","day"),sep = "-") %>% 
    separate(day,into = c("day","time"),sep = "T") %>%
    select(-c("time")) %>% 
    arrange(desc(year))

eq_INA$year =as.integer(eq_INA$year)
eq_INA$month =as.integer(eq_INA$month)
eq_INA$day =as.integer(eq_INA$day)
eq_INA$date = as.Date(with(eq_INA,paste(year,month,day,sep="-")), "%Y-%m-%d")

eq_INA 

# Checking missing values

eq_INA %>% is.na() %>% colSums() %>% sort(decreasing = TRUE)

# Earthquake classification based on magnitude

#Classifying earthquake based on magnitude richter scale

eq_INA = eq_INA %>% 
  mutate(mag_class = factor(
  ifelse( mag >= 2 & mag <= 4,"minor", 
  ifelse( mag >= 4 & mag <= 5,"light",
  ifelse( mag >= 5 & mag <= 6,"moderate",
  ifelse( mag >= 6 & mag <= 7,"strong",
  ifelse( mag >= 7 & mag <= 8,"major", "great")))))))

eq_INA
write.csv(eq_INA, "~/Dataset/Treated/EQ Indonesia 2000-2020.csv")

# counting the number of earthquake based on its level of magnitude and year.

eq_INA %>% 
  group_by(mag_class) %>% 
  summarise(number_of_earthquakes = n()) %>%
  arrange(number_of_earthquakes)

eq_INA %>% 
  group_by(mag_class) %>% 
  summarise(number_of_earthquakes = n()) %>%
  ggplot(aes(x = mag_class, y = number_of_earthquakes)) +
  geom_bar(stat = 'identity',fill = "red") + geom_label(aes(label = number_of_earthquakes)) + labs(title = 'Earthquake distribution based on their magnitude',
       subtitle = 'The smaller magnitude classes have the highest number.',
       caption = "The dataset contains list of recorded earthquake in Indonesia from year 2000-2020.",
       x = 'magnitude',
       y = 'Number of earthquakes')

ggsave(file="Earthquake distribution based on magnitude.png", width=10, height=5)

# Grouping: Year

eq_INA %>% 
  group_by(year) %>% 
  summarise(number_of_earthquakes = n()) %>%
  arrange(desc(year))

eq_INA %>% 
  group_by(year) %>% 
  summarise(number_of_earthquakes = n()) %>%
  ggplot(aes(x = year, y = number_of_earthquakes)) +
  geom_bar(stat = 'identity', fill ="blue") + geom_label(aes(label = number_of_earthquakes)) + 
  labs(title = 'Earthquake distribution based on number of earthquakes per year',
       subtitle = 'Years between 2005-2007, seen the highest seismic activity',
       caption = "The dataset contains list of recorded earthquakes in Indonesia from year 2000-2020.",
       x = 'Year',
       y = 'Number of earthquakes')

 
  ggsave(file="Earthquake distribution per year.png", width = 10, height = 5)

eq_INA %>%
  ggplot(aes(x = date, y = mag)) +
  geom_point(alpha = 0.3) + labs(title = 'Scatter plot of earthquakes distribution based on magnitude in range of 2000-2020',
       subtitle = 'There has been 4 great earthquake in the years of, 2004, 2005, 2007, and 2012.',
       caption = "The dataset contains list of recorded earthquake in Indonesia from year 2000-2020.",
       x = 'Year',
       y = 'Magnitude scale')

ggsave(file="Scatter plot of earthquakes distribution based on magnitude in 2000-2020.png", width = 10, height = 5)

eq_INA %>% 
  filter(year == 2004 | year == 2005 | year == 2006 | year == 2007) %>%
  group_by(mag_class, year) %>% 
  summarise(number_of_earthquakes = n()) %>%
  ggplot(aes(x = mag_class, y = number_of_earthquakes)) +
  geom_bar(stat = 'identity', fill ="forest green") +  geom_label(aes(label = number_of_earthquakes)) + facet_wrap(~year,  ncol=1, strip.position = "left") + 
  labs(title = 'Earthquake distribution based on magnitude in 2004-2007',
       subtitle = 'An increase on the number of minor earthquakes was noticed in 2005; double of the previous year.',
       caption = "The dataset contains list of recorded earthquake in Indonesia from year 2004-2007.",
       x = 'magnitude',
       y = 'Number of earthquakes')

ggsave(file="Earthquake distribution based on magnitude in 2004-2007.png", width = 10, height = 8)

eq_INA %>% 
  filter(year == 2004 | year == 2005 | year == 2006 | year == 2007) %>%
  group_by(month, year) %>% 
  summarise(number_of_earthquakes = n()) %>%
  ggplot(aes(x = month, y = number_of_earthquakes)) +
  geom_bar(stat = 'identity', fill ="forest green") +  geom_label(aes(label = number_of_earthquakes)) + facet_wrap(~year,  ncol=1, strip.position = "left") + 
  labs(title = 'Earthquake distribution based on magnitude per month in 2004-2007',
       subtitle = 'A signficant increase in the number of earthquakes occured prior to the great earthquake.',
       caption = "The dataset contains list of recorded earthquake in Indonesia from year 2004-2007.",
       x = 'Month',
       y = 'Number of earthquakes')

ggsave(file="Earthquake distribution based on magnitude per month in 2004-2007.png", width = 10, height = 5)

# Relationship between mag and depth

eq_INA %>%
  ggplot(aes(x = mag, y = depth)) +
  geom_point() +
  geom_smooth(method = 'lm', se = FALSE) +
  facet_wrap(~year)  + labs(title = 'Scatter plot of earthquake distribution based on magnitude and depth per year',
       subtitle = 'The blue line indicates that, the greater the magnitude, the smaller the depth.',
       caption = "The dataset contains list of recorded earthquake in Indonesia from year 2000-2020.",
       x = 'Magnitude',
       y = 'Depth')

ggsave(file="Scatter plot of earthquake distribution based on magnitude and depth per year.png", width = 10, height = 5)
