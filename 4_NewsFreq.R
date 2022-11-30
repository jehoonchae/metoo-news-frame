library(readr); library(dplyr); library(tidyverse)
library(lubridate); library(cowplot); library(hrbrthemes)
load("data_prep/metoo.RData")
df <- news
#Number of posts
nrow(df) #6412
head(df); glimpse(df)

range(df$date)

df <- df %>%
  filter(
    date > as.Date("2017-10-01"),  # complete months
    date < as.Date("2019-10-31")
  ) %>%
  mutate(
    year = as.integer(lubridate::year(date)),
    month = lubridate::month(date, label=TRUE, abbr=TRUE),
    wday = lubridate::wday(date, label=TRUE, abbr=TRUE),
    ym = as.Date(format(date, "%Y-%m-01")),
    week = floor_date(date, "week")
  )

# Frequency by week

freq_plot <- df %>% 
  # filter(press == 'MBN') %>% 
  count(week) %>% 
  arrange(week) %>% 
  ggplot(aes(week, n)) +
  geom_line() +
  # ggforce::geom_bspline0() +
  scale_x_date(date_breaks = "3 month", date_labels='%Y-%m'
               # , expand=c(0,0.5)
               ) +
  # scale_y_continuous(expand=c(0,0)) +
  theme_minimal_hgrid(font_size = 15) +
  # theme_ipsum_ps(grid="XY") +
  labs(
    x=NULL, y=NULL
    , title="Frequencey of News on Me too movement"
    , subtitle = "October 2017 - October 2019 (by week)"
  ) 

ggsave2(freq_plot, filename = 'freq_plot_slide.png', dpi = 'retina'
        , width = 20, height = 10, units = 'cm')

df %>% 
  group_by(press) %>% 
  count() %>% 
  arrange(desc(n))

nrow(df)

# word freq
freq_df <- read_csv('data_prep/freq_dist_100.csv')
colnames(freq_df) <- c('term', 'frequency')
typeof(freq_df$term)
freq_df$term <- as.factor(freq_df$term)
freq_df <- freq_df[1:50,1:2]

library(translateR)
my_api_key <- 'AIzaSyDN9UhOIEXV052aUi2fhqEPtByM_-sA-5M'
freq_df$term <- as.character(freq_df$term)
freq_df_trans <- translate(dataset=freq_df, content.field='term', 
                           google.api.key=my_api_key,
                           source.lang='ko', target.lang='en')

# print(freq_df_trans, n=nrow(freq_df_trans))
# freq_df_trans$translatedContent[freq_df_trans$translatedContent=='Apple'] <- 'Apology'
freq_term_plot <- freq_df_trans %>% 
  mutate(translatedContent = as.factor(translatedContent)) %>% 
  ggplot(aes(x=reorder(translatedContent, -frequency), y=frequency)) +
  geom_bar(stat = 'identity') +
  theme_bw(base_size = 12) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  # coord_flip() +
  labs(x=NULL, y='Frequency', title="Top-50 terms (translated to English)")
ggsave2(plot = freq_term_plot, filename = 'freq_term_plot.png', dpi = 'retina'
        , width = 20, height = 12, units = 'cm')
