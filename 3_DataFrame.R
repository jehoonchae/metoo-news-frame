library(readr); library(lubridate); library(dplyr)

getwd()
# news <- read_csv('data_prep/metoo_1021.csv', col_names = T)
news_chosun <- read_csv('data_prep/metoo_chosun.csv', col_names = T)
news_chosun <- news_chosun %>% filter(dindex >= 0)
news_chosun <- 
  news_chosun %>% 
  distinct()
nrow(news_chosun)
colnames(news_chosun)
# names(news)

nrow(news) # 6213

news <- 
  news %>% 
  distinct()

nrow(news) # 6213

colnames(news) <- c('date', 'press', 'title', 'article')

press_list <- unique(news$press)

news %>% 
  group_by(press) %>% 
  count() %>% 
  arrange(desc(n))

data <- news
nrow(data)
colnames(data)

# Ideology of press
data$ideo <- ifelse((data$press == '조선일보')|(data$press == '동아일보')
                    |(data$press == '채널A')|(data$press == 'TV조선'), 'conservative', 'liberal')
data$ideo <- factor(data$ideo, levels = c('conservative', 'liberal'))

#Duplication Check
data <- data %>% 
  distinct(pos, .keep_all = TRUE)
dim(data)

#Data type control
data$press <- as.factor(data$press)
# data$date <- as.factor(data$dindex)

write_csv(data, "data_prep/metoo.csv", col_names = T)

news_chosun$ideo <- 'conservative'
news_chosun$ideo <- factor(news_chosun$ideo, levels = c('conservative', 'liberal'))

write_csv(news_chosun, "data_prep/metoo_chosun.csv", col_names = T)

news <- read_csv("data_prep/metoo.csv", col_names = T)
news_chosun <- read_csv("data_prep/metoo_chosun.csv", col_names = T)
news <- news %>% filter(!(press == '조선일보'))
news <- rbind(news, news_chosun)
news <- news %>% arrange(date)

save(news, file = "data_prep/metoo.RData")

# word2vec

LiberalNews <- news %>% filter(ideo == "liberal")
ConservativeNews <- news %>% filter(ideo == "conservative")
write_csv(LiberalNews, path = "word2vec/LibNews.csv", col_names=T)
write_csv(ConservativeNews, path = "word2vec/ConNews.csv", col_names=T)
write_csv(news, path="word2vec/News.csv", col_names = T)


