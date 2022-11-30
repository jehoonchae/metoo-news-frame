library(tidyverse); library(tidytext); library(readr)
library(stm); library(tm); library(quanteda); library(tidystm)
library(stminsights); library(cowplot); library(ggthemes)

load("data_prep/metoo.RData")
load("stmmodel40_3355.RData")

labelTopics(stmmodel40, c(1:40), n = 20)
# 
topic_summary <- plot(stmmodel40
     , type = "summary"
     , custom.labels = ''
     , xlim=c(0,.08)
     , topic.names = topic_names
     , topics = c(1,3,4,5,6,7,8,10,11,12,13,14,15,16,17,19,21,22,23,24,
                  25,26,27,28,29,30,31,32,33,35,36,37,38,39,40)
     )

ggsave(filename = 'topic_summary.png', plot = topic_summary 
        # , width = 20
        # , height = 12
        # , units = 'cm'
        )


topic_names <- c('Ministry of Gender Equality and Family (5)',
                 'Conspiracy Theory (1)',
                 '#MeToo Democratic Party politician (1)',
                 'Reinvestigation Jang Ja Yeon (5)',
                 '#MeToo Ice Sports (2)',
                 '#MeToo Governor Ahn Heejung (1)',
                 'Victims of Sexual Violence (6)',
                 'Feminism (6)',
                 '#MeToo Yang Ye Won (4)',
                 'Rally (6)',
                 '#MeToo Seoul Mayor Candidate Jung BongJu (1)',
                 '#MeToo Theater, Lee YoonTaek (2)',
                 '#MeToo Poet, Go Eun (2)',
                 'With You, Japanese Military Sexual Slavery (6)',
                 '#MeToo, TV celebrity (2)',
                 '#MeToo Actor, Cho Min Ki, Oh Dal Soo (2)',
                 '#MeToo in U.S. (Trump, Kavanaugh) (4)',
                 'Gender Inequality (6)',
                 '#MeToo in Hollywood (4)',
                 '#MeToo, Director, Kim Ki Duk (2)',
                 '#MeToo Hospital, Doctor, Nurse (3)',
                 'Criminal Investigation (5)',
                 '#MeToo School (3)',
                 '#MeToo, False Accusation (2)',
                 'Bill Pass at National Assembly (5)',
                 'Institutional Measures about Sexual Assault (5)',
                 '#MeToo Go (Baduk) (2)', 
                 '#MeToo Asiana Airline (3)', 
                 '#MeToo Swedish Academy (4)',
                 'Sex Education (5)', 
                 '#MeToo Prosecutor, Seo Ji Hyun (3)', 
                 '#MeToo Catholic (3)',
                 '#MeToo in Japan (4)', 
                 'Hidden Camera Video in Online Problem (5)', 
                 '#MeToo Beauty Contest (2)')
td_beta <- tidy(stmmodel40)
td_beta
td_gamma <- tidy(stmmodel40, matrix = "gamma")
td_gamma

top_terms <- td_beta %>%
  arrange(beta) %>%
  group_by(topic) %>%
  top_n(7, beta) %>%
  arrange(-beta) %>%
  select(topic, term) %>%
  summarise(terms = list(term)) %>%
  mutate(terms = map(terms, paste, collapse = ", ")) %>% 
  unnest()

gamma_terms <- td_gamma %>%
  group_by(topic) %>%
  summarise(gamma = mean(gamma)) %>%
  arrange(desc(gamma)) %>%
  left_join(top_terms, by = "topic") %>%
  mutate(topic = paste0("Topic ", topic),
         topic = reorder(topic, gamma))
gamma_terms <- gamma_terms %>% 
  dplyr::filter(!(topic == 'Topic 2')) %>% 
  dplyr::filter(!(topic == 'Topic 9')) %>% 
  dplyr::filter(!(topic == 'Topic 18')) %>%
  dplyr::filter(!(topic == 'Topic 20')) %>% 
  dplyr::filter(!(topic == 'Topic 34'))
sum(gamma_terms$gamma)

gamma_terms %>% 
  mutate(prop = round(gamma*1/sum(gamma_terms$gamma)*100,2)) %>% 
  select(topic, prop) %>% 
  print(n=nrow(gamma_terms))
print(gamma_terms, n=nrow(gamma_terms))
# gamma_terms %>%
#   top_n(20, gamma) %>%
#   ggplot(aes(topic, gamma, label = terms, fill = topic)) +
#   geom_col(show.legend = FALSE) +
#   geom_text(hjust = 0, nudge_y = 0.0005, size = 3,
#             family = "IBMPlexSans") +
#   coord_flip() +
#   scale_y_continuous(expand = c(0,0),
#                      limits = c(0, 0.09),
#                      labels = percent_format()) +
#   theme_tufte(base_family = "IBMPlexSans", ticks = FALSE) +
#   theme(plot.title = element_text(size = 16,
#                                   family="IBMPlexSans-Bold"),
#         plot.subtitle = element_text(size = 13)) +
#   labs(x = NULL, y = expression(gamma),
#        title = "Top 20 topics by prevalence in the Hacker News corpus",
#        subtitle = "With the top words that contribute to each topic")


# 
prep <- estimateEffect(1:40 ~ ideo+s(date), stmmodel40, meta = meta_metoo, uncertainty = "Global")
# prep_inter <- estimateEffect(1:40 ~ ideo*s(date), stmmodel40, meta = meta_metoo, uncertainty = "None")


# ideo_estimate <- get_effects(estimates=prep, variable='ideo', type='pointestimate') %>% arrange(difference)
ideo_effects <- get_effects(estimates=prep, variable='ideo', type='difference', 
                            cov_val1="Conservative", cov_val2="Liberal") %>% 
  dplyr::filter(!(topic == '2')) %>% 
  dplyr::filter(!(topic == '9')) %>% 
  dplyr::filter(!(topic == '18')) %>%
  dplyr::filter(!(topic == '20')) %>% 
  dplyr::filter(!(topic == '34')) %>% 
  arrange(difference)
# print(ideo_effects, n=40)
ideo_effects$topic <- factor(ideo_effects$topic, 
                             levels = ideo_effects$topic[order(ideo_effects$difference)])
ideo_effects %>% print(n=nrow(ideo_effects))
ideo_effects$lower[ideo_effects$topic == 37] <- 
  ideo_effects$lower[ideo_effects$topic == 37] - 0.0007
ideo_effects$lower[ideo_effects$topic == 24] <- 
  ideo_effects$lower[ideo_effects$topic == 24] + 0.0006


(ideo_plot <- 
    ideo_effects %>% 
    ggplot(aes(topic, difference)) + 
    # geom_point(aes(colour = difference), size=5) +
    # geom_errorbar(aes(ymin = lower, ymax = upper, colour=difference), width = .1, size=.5) +
    # scale_colour_gradient2() +
    geom_point(aes(colour=(lower>0)|(upper<0)), size=5) +
    geom_errorbar(aes(ymin=lower, ymax=upper, colour=(lower>0)|(upper<0)), width=.1, size=.5) +
    scale_colour_manual(values=c("black","firebrick")) +
    # scale_colour_brewer(palette = "RdBu", type = "seq") +
    geom_hline(yintercept=0, linetype='longdash') +
    scale_y_continuous(limits=c(-.05,.05)) +
    labs(x = '', y = '          Liberal ↔ Conservative') +
    guides(colour=FALSE) +
    # theme_bw() +
    theme_minimal(15) +
    theme(panel.grid.minor=element_blank()
          , panel.grid.major.x=element_blank()
          , axis.line.y=element_line(size=.8)
          # , axis.line.x = element_blank()
          , axis.text.x=element_blank()
          , axis.ticks.x.bottom=element_blank()
          , legend.position="none") +
    # coord_flip()
    ggplot2::annotate("text", x=11, y=-.018, hjust=0, fontface=2
                      , label='Topics Dominant in Liberal News Media') +
    ggplot2::annotate("text", x=c(11,11,11,11,11,11,11,11,11,11)
                      , y=c(-.021,-.024,-.027,-.03,-.033,-.036,-.039,-.042,-.045,-.048)
                      , label=c("(3) #MeToo Yang Ye Won"
                                ,"(5) Bill Pass at National Assembly"
                                ,"(5) Sex Education"
                                ,"(6) Gender Inequality"
                                ,"(5) Reinvestigation Jang Ja Yeon"
                                ,"(3) #MeToo School"
                                ,"(5) Institutional Measures about Sexual Assault"
                                ,"(6) Rally"
                                ,"(6) Victims of Sexual Violence"
                                ,"(6) With You, Japanese Military Sexual Slavery")
                      , hjust=0
                      # , vjust=0
    ) +
    geom_segment(aes(x=11,y=-.021,xend=10,yend=ideo_effects$difference[10]-.0017), size=.1, colour="grey70") +
    geom_segment(aes(x=11,y=-.024,xend=9,yend=ideo_effects$difference[9]-.0017), size=.1, colour="grey70") +
    geom_segment(aes(x=11,y=-.027,xend=8,yend=ideo_effects$difference[8]-.0017), size=.1, colour="grey70") +
    geom_segment(aes(x=11,y=-.030,xend=7,yend=ideo_effects$difference[7]-.0017), size=.1, colour="grey70") +
    geom_segment(aes(x=11,y=-.033,xend=6,yend=ideo_effects$difference[6]-.0017), size=.1, colour="grey70") +
    geom_segment(aes(x=11,y=-.036,xend=5,yend=ideo_effects$difference[5]-.0017), size=.1, colour="grey70") +
    geom_segment(aes(x=11,y=-.039,xend=4,yend=ideo_effects$difference[4]-.0017), size=.1, colour="grey70") +
    geom_segment(aes(x=11,y=-.042,xend=3,yend=ideo_effects$difference[3]-.0017), size=.1, colour="grey70") +
    geom_segment(aes(x=11,y=-.045,xend=2,yend=ideo_effects$difference[2]-.0017), size=.1, colour="grey70") +
    geom_segment(aes(x=11,y=-.048,xend=1,yend=ideo_effects$difference[1]-.0017), size=.1, colour="grey70") +
    
    ggplot2::annotate("text", x=25, y=.048, hjust=1, fontface=2
                      , label='Topics Dominant in Conservative News Media') +
    ggplot2::annotate("text", x = c(25,25,25,25,25,25,25,25,25,25)
                      , y = c(.045,.042,.039,.036,.033,.03,.027,.024,.021,.018)
                      , label = c("#MeToo, False Accusation (2)"
                                  ,"#MeToo Seoul Mayor Candidate Jung BongJu (1)"
                                  ,"Hidden Camera Video in Online Problem (5)"
                                  ,"#MeToo, TV celebrity (2)"
                                  ,"#MeToo Governor Ahn Heejung (1)"
                                  ,"#MeToo in U.S. (Trump, Kavanaugh) (4)"
                                  ,"#MeToo in Hollywood (4)"
                                  ,"#MeToo Poet, Go Eun (2)"
                                  ,"#MeToo Democratic Party politician (1)"
                                  ,"#MeToo Actor/Director, Kim Ki Duk (2)")
                      , hjust=1
                      # , vjust=0
    ) +
    geom_segment(aes(x=25,y=.045,xend=35,yend=ideo_effects$difference[35]+.0017), size=.1, colour="grey70") +
    geom_segment(aes(x=25,y=.042,xend=34,yend=ideo_effects$difference[34]+.0017), size=.1, colour="grey70") +
    geom_segment(aes(x=25,y=.039,xend=33,yend=ideo_effects$difference[33]+.0017), size=.1, colour="grey70") +
    geom_segment(aes(x=25,y=.036,xend=32,yend=ideo_effects$difference[32]+.0017), size=.1, colour="grey70") +
    geom_segment(aes(x=25,y=.033,xend=31,yend=ideo_effects$difference[31]+.0017), size=.1, colour="grey70") +
    geom_segment(aes(x=25,y=.03,xend=30,yend=ideo_effects$difference[30]+.0017), size=.1, colour="grey70") +
    geom_segment(aes(x=25,y=.027,xend=29,yend=ideo_effects$difference[29]+.0017), size=.1, colour="grey70") +
    geom_segment(aes(x=25,y=.024,xend=28,yend=ideo_effects$difference[28]+.0017), size=.1, colour="grey70") +
    geom_segment(aes(x=25,y=.021,xend=27,yend=ideo_effects$difference[27]+.0017), size=.1, colour="grey70") +
    geom_segment(aes(x=25,y=.018,xend=26,yend=ideo_effects$difference[26]+.0017), size=.1, colour="grey70")
  
)

ggsave2(filename = 'IdeoPlot35_slide.png', plot = ideo_plot, units = 'cm', dpi = 'retina', height = 15, width = 22)


prep <- estimateEffectDEV(c(7,13,4,3)&c(19,24,14,15,6,31,28,40)&c(27,36,11,37,32,25)
                          &c(23,21,33,38)&c(26,30,39,29,25,1,5)&c(8,16,12,10,22)~ 
                            ideo, stmmodel40, meta = meta_metoo, group = T)

ideo_effects <- get_effects(estimates=prep, variable='ideo', type='difference', 
                            cov_val1="Conservative", cov_val2="Liberal")
ideo_effects$topic <- factor(ideo_effects$topic, levels= unique(ideo_effects$topic), 
                       labels=c('Politics', 'Art, Culture, & Sports'
                                , 'Other Fields','Other Countries'
                                , 'Institutional Measures, Alternatives'
                                ,'Gender Equality'), )
ideo_effects %>% 
  ggplot(aes(topic, difference)) + 
  # geom_point(aes(colour = difference), size=5) +
  # geom_errorbar(aes(ymin = lower, ymax = upper, colour=difference), width = .1, size=.5) +
  # scale_colour_gradient2() +
  geom_point(aes(colour=(lower>0)|(upper<0)), size=5) +
  geom_errorbar(aes(ymin=lower, ymax=upper, colour=(lower>0)|(upper<0)), width=.1, size=.5) +
  scale_colour_manual(values=c("black","firebrick")) +
  # scale_colour_brewer(palette = "RdBu", type = "seq") +
  geom_hline(yintercept=0, linetype='longdash') +
  scale_y_continuous(limits=c(-.1,.1)) +
  labs(x = '', y = '          Liberal ↔ Conservative') +
  guides(colour=FALSE) +
  # theme_bw() +
  theme_minimal(15) +
  coord_flip()
  