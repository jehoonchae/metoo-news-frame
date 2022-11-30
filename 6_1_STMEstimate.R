library(tidyverse); library(tidytext); library(readr); library(drlib)
library(stm); library(tm); library(quanteda); library(tidystm)
library(stminsights); library(cowplot); library(ggthemes)

# data <- read_csv('data_prep/metoo.csv', col_names = T)
load("data_prep/metoo.RData")
# load("stmmodel40_2123.RData")
load("stmmodel40_3355.RData")
data <- news
# Data type control
data$press <- as.factor(data$press)
data$date <- as.factor(data$dindex)
data$ideo <- as.factor(data$ideo)
names(data)
data = subset(data, select = c(pos, press, date, ideo, article))
nrow(data)
data <- data %>% 
  filter(!is.na(press)) %>% 
  filter(!is.na(date)) %>% 
  filter(!is.na(ideo))

# From now this is for STM structure
#corpus <- corpus(data$pos)

typeof(data$press); typeof(data$date)
unique(data$press)

corpus <- corpus(data$pos)
docvars(corpus, field='press') <- data$press
docvars(corpus, field='date') <- data$date
docvars(corpus, field='ideo') <- data$ideo
# docvars(corpus, field='time') <- data$time

#DFM(Document-Feature Matrix)
dfm <- dfm(dfm(corpus,tolower=F,stem=F))
dfm <- dfm_trim(dfm, max_docfreq = .99, min_docfreq = 0.005, docfreq_type = "prop")

#DFM for stm model
stmdfm <- convert(dfm, to = "stm", docvars = docvars(corpus))
out <- prepDocuments(stmdfm$documents, stmdfm$vocab, stmdfm$meta, lower.thresh = 10)

# HAVE TO MAKE TYPE AS NUMERIC FOR STM!!!!!!!!
out$meta$press <- as.numeric(out$meta$press)
out$meta$date <- as.numeric(out$meta$date)
out$meta$ideo <- as.numeric(out$meta$ideo)
meta_metoo <- out$meta

typeof(out$meta$press); typeof(out$meta$date)

# short = strtrim(data$article, 300)
# rm(data, dfm, stmdfm, corpus)

#Make STM model
# K = 40
# seed = 2123
# seed = 3355

# stmmodel40 <- stm(out$documents,
#                       out$vocab,
#                       K = K,
#                       prevalence = ~ s(date)*press*ideo,
#                       # max.em.its = 75,
#                       data = meta_metoo,
#                       seed = seed)
# save(meta_metoo, stmmodel40, meta_metoo, file='stmmodel40_3355.RData')
################################################################################
