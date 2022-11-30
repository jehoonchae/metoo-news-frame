w2v <- read_csv('topic_8.csv', col_names = T) %>% select(-X1)
w2v_con <- read_csv('topic_8_con.csv', col_names = T) %>% select(-X1)
w2v_lib <- read_csv('topic_8_lib.csv', col_names = T) %>% select(-X1)

library(translateR)
my_api_key <- 'AIzaSyDN9UhOIEXV052aUi2fhqEPtByM_-sA-5M'

w2v <- translate(dataset=w2v, content.field='kor', 
                           google.api.key=my_api_key,
                           source.lang='ko', target.lang='en')
# colnames(w2v_lib)[colnames(w2v_lib) == 'translatedContent'] <- "eng"
w2v$eng <- w2v$translatedContent
w2v_lib$eng[w2v_lib$kor == '무고'] <- 'False Accusation'
w2v_lib$eng[w2v_lib$kor == '성폭력'] <- 'Sexual Violence'
w2v_lib$eng[w2v_lib$kor == '용기'] <- 'Courage'
w2v_lib$eng[w2v_lib$kor == '가해자'] <- 'Attacker'
w2v_lib$eng[w2v_lib$kor == '피해자'] <- 'Victim'

w2v_lib$colour <- w2v_lib$kor
w2v_lib$colour <- ifelse(w2v_lib$kor == '가해자', 1, 
                     ifelse(w2v_lib$kor == '피해자', 1,
                            ifelse(w2v_lib$kor == '성폭력', 1,
                                   ifelse(w2v_lib$kor == '용기', 1,
                                          ifelse(w2v_lib$kor == '무고', 1, 0)))))

w2v_plot <- list()
w2v_plot[[1]] <- w2v %>% 
  ggplot(aes(x=PC1, y=PC2, label=eng)) +
  geom_text(aes(colour=(colour==1), size=(colour==1))) +
  scale_colour_manual(values=c("grey40","red")) +
  scale_size_manual(values=c(3,4)) +
  theme_test(12) +
  labs(x=NULL, y=NULL, title='News Media (Total)') +
  theme(legend.position = "none")

w2v_plot[[2]] <- w2v_con %>% 
  ggplot(aes(x=PC1, y=PC2, label=eng)) +
  geom_text(aes(colour=(colour==1), size=(colour==1))) +
  scale_colour_manual(values=c("grey40","red")) +
  scale_size_manual(values=c(3,4)) +
  theme_test(12) +
  labs(x=NULL, y=NULL, title='Conservative') +
  theme(legend.position = "none")

w2v_plot[[3]] <- w2v_lib %>% 
  ggplot(aes(x=PC1, y=PC2, label=eng)) +
  geom_text(aes(colour=(colour==1), size=(colour==1))) +
  scale_colour_manual(values=c("grey40","red")) +
  scale_size_manual(values=c(3,4)) +
  theme_test(12) +
  labs(x=NULL, y=NULL, title='Liberal') +
  theme(legend.position = "none")

w2v_grid <- grid.arrange(grobs=w2v_plot, ncol = 3)
ggsave2(plot = w2v_grid, filename = 'w2v_plot.png', width = 13, height = 5, dpi = 300)
