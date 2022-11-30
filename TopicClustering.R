library(ggdendro)

tidy_stm <- tidy(stmmodel40)
tidy_stm <- tidy_stm %>% 
  dplyr::filter(!(topic == '9')) %>% 
  dplyr::filter(!(topic == '18')) %>% 
  dplyr::filter(!(topic == '20')) %>% 
  dplyr::filter(!(topic == '34'))
# print(tidy_stm, n=40)

tidy_stm_50 <- tidy_stm %>% group_by(topic) %>% top_n(n = 50, wt = beta)  
tidy_stm_100 <- tidy_stm %>% group_by(topic) %>% top_n(n = 100, wt = beta)  
tidy_stm_200 <- tidy_stm %>% group_by(topic) %>% top_n(n = 200, wt = beta)  
tidy_stm_300 <- tidy_stm %>% group_by(topic) %>% top_n(n = 300, wt = beta)  

tidy_stm <- tidy_stm %>% 
  spread(key=term, value=beta) %>% 
  select(-topic) %>% 
  select(unique(tidy_stm_300$term))

rownames(tidy_stm)  <- c('Ministry of Gender Equality and Family'
                         , 'TV Program'
                         , 'Conspiracy theory'
                         , 'Democratic Party'
                         , 'Jang Jayeon'
                         , '#MeToo Ice Sports'
                         , '#MeToo Ahn Heejung'
                         , 'Victims of Sexual Violence'
                         , 'Feminism'
                         , 'Petition, Yang YeWon, Suzy'
                         , '#MeToo Rally'
                         , '#MeToo Seoul Mayor Candidate Jung Bongju'
                         , '#MeToo theater company, Lee YoonTaek'
                         , '#MeToo Poet, GoEun'
                         , 'Comfort Women, #WithYou'
                         , '#MeToo Entertainer, Kim Saengmin'
                         , '#MeToo Actor, Cho MinKi'
                         # , 'Movie'
                         , '#MeToo in America (Trump, Kavanaugh)'
                         , 'Gender Inequality'
                         , '#MeToo in Hollywood'
                         , '#MeToo Movie Actor, Cho JaeHyun, Kim KiDuk'
                         , '#MeToo Hospital, Doctor, Nurse'
                         , 'Criminal Investigation'
                         , 'School #MeToo'
                         , '#MeToo Movie Actor'
                         , 'Bill Pass at National Assembly'
                         , 'Institutional Arternatives about Sexual Assault'
                         , '#MeToo Go Player'
                         , '#MeToo Asiana Airline'
                         , '#MeToo Swedish Academy'
                         , 'Sex Education'
                         , '#MeToo Prosecutor Seo JiHyun'
                         , '#MeToo Catholic'
                         , '#MeToo in Japan'
                         , 'Hidden Camera Video in Online Problem'
                         , '#MeToo Beauty Contest')

dist_mat <- dist(tidy_stm, method = "manhattan")
hclust_avg <- hclust(dist_mat, method = 'ward.D2')

dend <- hclust_avg %>% as.dendrogram()
ggd1 <- as.ggdend(dend)
# install.packages('sets')
library(sets)
dend %>% set("branches_k_color", k = 2) %>% plot(main = "Default colors")

# install.packages('factoextra')
library(factoextra)

fviz_dend(hclust_avg, k = 9
          , color_labels_by_k = TRUE
          # , rect = TRUE
          , main = NULL
          , rect_fill = F
          , ggtheme = theme_void()
) + ylim(-5,3)


################################################################################
################################################################################
################################################################################
#만약 색조가 들어간 군집분석결과를 그래프로 그리면 다음과 같다. 
#우선은 dendextend 라이브러리를 구동해야 한다. 
library('dendextend')
#우선은 덴드로그램 그림을 저장한다. 
dend <- as.dendrogram(myclusters)
#몇 개의 집단을 선정할지를 결정하였다. 
myk <- 8
#덴드로그램의 선의 색깔을 다르게 설정하였다. 
dend <- dend %>%
  color_branches(k = myk) %>%
  color_labels(dend, k=myk) %>%
  set("branches_lwd", 2) %>%
  set("branches_lty", 1)
plot(dend,main="Clustering documents",ylab="Height",
     ylim=c(0,30))
################################################################################
################################################################################
################################################################################
# install.packages("ape")
# library("ape")
# plot(as.phylo(hclust_avg))
# plot(as.phylo(hclust_avg), type = "unrooted", cex = 0.6,
#      no.margin = TRUE)
# plot(as.phylo(hclust_avg), type = "fan")


ggdendrogram(hclust_avg) + 
  coord_cartesian(ylim=c(1.3,3))

plot(hclust_avg)
plot(hclust_avg, hang = -1, cex = 0.8)
rect.hclust(hclust_avg , k = 7, border = 2:6)
abline(h = 1.95, col = 'red')


tidy_stm %>% 
  group_by(topic) %>% 
  top_n(10, beta) %>% 
  ungroup() %>%
  mutate(topic = paste0("Topic ", topic),
         term = reorder_within(term, beta, topic)) %>%
  ggplot(aes(term, beta, fill = as.factor(topic))) +
  geom_col(alpha = 0.8, show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free_y") +
  coord_flip() +
  scale_x_reordered() +
  labs(x = NULL, y = expression(beta),
       title = "Highest word probabilities for each topic",
       subtitle = "Different words are associated with different topics") +
  theme_bw(base_family = "NanumGothic")