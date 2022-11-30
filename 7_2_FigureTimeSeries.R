library(tidyverse); library(tidytext); library(readr)
library(stm); library(tm); library(quanteda); library(tidystm)
library(stminsights); library(cowplot); library(ggthemes); library(gridExtra)

load("data_prep/metoo.RData")
load("stmmodel40_3355.RData")

prep <- estimateEffect(1:40 ~ ideo+s(date), stmmodel40, meta = meta_metoo, uncertainty = "Global")
prep_inter <- estimateEffect(1:40 ~ ideo*s(date), stmmodel40, meta = meta_metoo, uncertainty = "None")

effect_date <- get_effects(estimates = prep_inter,
                           variable = 'date',
                           type = 'continuous',
                           moderator = 'ideo',
                           modval = 1) %>%
  bind_rows(
    get_effects(estimates = prep_inter,
                variable = 'date',
                type = 'continuous',
                moderator = 'ideo',
                modval = 2)
  ) %>% 
  dplyr::filter(!((topic == '9') | (topic == '18') | (topic == '34')))

# meta_metoo$dindex <- meta_metoo$date - 1
# meta_metoo$date_num <- meta_metoo$date
# meta_metoo$date <- meta_metoo$`news$date`
# meta_metoo <- meta_metoo %>% select(news$date)
# meta_metoo <- cbind(meta_metoo, news$date)
# effect_date <- effect_date %>% 
#   select(value, proportion, topic, lower, upper, moderator)
# effect_date <- effect_date %>% 
#   mutate(moderator = as.factor(moderator)) %>% 
#   mutate(date_num = round(value, 0))  
# 
# meta_metoo$date <- ymd(df$project_posted_date)
# min_date <- min(meta_metoo$date) %>% 
#   as.numeric()
# meta_metoo$date_num <- as.numeric(meta_metoo$date) - min_date
# 
# effect_date <- effect_date %>% left_join(meta_metoo %>% select(date, date_num)) %>% distinct()

effect_date %>% 
  mutate(moderator = as.factor(moderator)) %>% 
  # filter(!(topic == 23)) %>%
  filter(topic == 30) %>% 
  ggplot(aes(x = value, y = proportion, color = moderator, group = moderator, linetype = moderator)) +
  # ggplot(aes(x = date, y = proportion, color = moderator, group = moderator, linetype = moderator)) +
  geom_line() +
  # scale_x_date(date_break = '3 months', date_labels = "%b/%y") +
  scale_color_manual(values = c("firebrick", "#182160")) +
  scale_linetype_manual(values = c('longdash', 'solid')) +
  # geom_ribbon(aes(ymin = lower, ymax = upper), alpha = 0.2)  +
  # theme_light() +
  theme_test() +
  # facet_wrap(~ topic)
  theme(legend.position = 'none') +
  labs(x = 'Period', y = 'Topic Prevalence')

plot_40 <- list()
for (i in c(1:40)){
  plot_40[[i]] <- effect_date %>% 
  mutate(moderator = as.factor(moderator)) %>% 
  filter(topic == i) %>% 
  ggplot(aes(x = value, y = proportion, color = moderator, group = moderator, linetype = moderator)) +
  geom_line() +
  scale_color_manual(values = c("firebrick", "#182160")) +
  scale_linetype_manual(values = c('longdash', 'solid')) +
  theme_test() +
  theme(legend.position = 'none') +
  labs(x = NULL, y = NULL, title = paste0("Topic", i))
  }
grid.arrange(grobs=plot_40, ncol=5)

# library(ggraph)
# 
# stm_corrs <- get_network(model = stmmodel40,
#                          method = 'simple',
#                          labels = paste('Topic', 1:40),
#                          cutoff = 0.001,
#                          cutiso = TRUE)
# # NOT RUN {
# # plot network
# ggraph(stm_corrs
#        # , "dendrogram"
#        # , layout = 'fr'
#        ) +
#   geom_edge_link(
#     aes(edge_width = weight),
#     label_colour = '#fc8d62',
#     edge_colour = '#377eb8') +
#   geom_node_point(size = 4, colour = 'black')  +
#   geom_node_label(
#     aes(label = name, size = props),
#     colour = 'black',  repel = TRUE, alpha = 0.85) +
#   scale_size(range = c(2, 10), labels = scales::percent) +
#   labs(size = 'Topic Proportion',  edge_width = 'Topic Correlation') +
#   scale_edge_width(range = c(1, 3)) +
#   theme_graph()
# # }


source('estimateEffectDEV.R')
prep <- estimateEffectDEV(c(7,13,4,3)&c(19,24,14,15,6,31,28,40)&c(27,36,11,37,32,25)
                          &c(23,21,33,38)&c(26,30,39,29,25,1,5)&c(8,16,12,10,22)~ 
                            ideo*s(date), stmmodel40, meta = meta_metoo, group = T)

# topic_selected <- c(1,3,4,5,6,7,8,10,11,12,13,14,15,16,17,19,21,22
#                     ,23,24,25,26,27,28,29,30,31,32,33,35,36,37,38,39,40)
effect <- get_effects(estimates = prep, variable = 'date', type = 'continuous')
effect$topic <- factor(effect$topic, levels= unique(effect$topic), 
                       labels=c('Politics', 'Art, Culture, & Sports'
                                , 'Other Fields','Other Countries'
                                , 'Institutional Measures, Alternatives'
                                ,'Gender Equality'), )
effect %>% 
  ggplot(aes(x = value, y = proportion
             # , group = topic
             # , colour = topic
  )) +
  # ggplot(aes(x = date, y = proportion, color = moderator, group = moderator, linetype = moderator)) +
  geom_line(size=.5) +
  # scale_x_date(date_break = '3 months', date_labels = "%b/%y") +
  # scale_color_manual(values = c("firebrick", "#182160")) +
  # scale_linetype_manual(values = c('longdash', 'solid')) +
  # geom_ribbon(aes(ymin = lower, ymax = upper), alpha = 0.2)  +
  theme_light() +
  # theme_bw() +
  # theme_test() +
  facet_wrap(~ topic) +
  labs(x = 'Period', y = 'Topic Prevalence')

effect_date <- get_effects(estimates = prep,
                           variable = 'date',
                           type = 'continuous',
                           moderator = 'ideo',
                           modval = 1) %>%
  bind_rows(
    get_effects(estimates = prep,
                variable = 'date',
                type = 'continuous',
                moderator = 'ideo',
                modval = 2)
  )
unique(effect_date$topic)
effect_date$topic <- factor(effect_date$topic, levels= unique(effect_date$topic), 
                            labels=c('Politics', 'Art, Culture, & Sports'
                                     , 'Other Fields','Other Countries'
                                     , 'Institutional Measures, Alternatives'
                                     ,'Gender Equality'), )

# colnames(effect_date)[colnames(effect_date)=='moderator'] <- 'Ideology'
plot_date <- list()

category <- c('Politics', 'Art, Culture, & Sports'
              , 'Other Fields','Other Countries'
              , 'Institutional Measures, Alternatives'
              ,'Gender Equality')

for (i in category){
  plot_date[[i]] <- effect_date %>% 
    mutate(Ideology = as.factor(moderator)) %>% 
    filter(topic == i) %>%
    ggplot(aes(x = value, y = proportion, color = Ideology, 
               group = Ideology, linetype = Ideology)) +
    geom_line(size=1) +
    scale_color_manual(values = c("firebrick", "#182160"), 
                       labels=c("Conservative", "Liberal")) +
    scale_linetype_manual(values = c('longdash', 'solid'), 
                          labels=c("Conservative", "Liberal")) +
    theme_bw(15) +
    guides(color=F, linetype=F) +
    labs(x = NULL, y = NULL, title=paste0(i))
}

# plot_date

date_grid <- grid.arrange(grobs=plot_date, ncol = 3)
ggsave2(plot = date_grid, filename = 'date_grid.png', width = 12, height = 5.5, dpi = 300)

p1 <- effect_date %>% 
  mutate(Ideology = as.factor(Ideology)) %>% 
  filter(topic == 'Politics') %>%
  ggplot(aes(x = value, y = proportion, color = Ideology, group = Ideology, linetype = Ideology)) +
  # ggplot(aes(x = date, y = proportion, color = Ideology, group = Ideology, linetype = Ideology)) +
  geom_line(size=1) +
  # scale_x_date(date_break = '3 months', date_labels = "%b/%y") +
  scale_color_manual(values = c("firebrick", "#182160"), labels=c("Conservative", "Liberal")) +
  scale_linetype_manual(values = c('longdash', 'solid'), labels=c("Conservative", "Liberal")) +
  # geom_ribbon(aes(ymin = lower, ymax = upper), alpha = 0.2)  +
  # theme_light() +
  theme_bw(15) +
  # guides(color=F, linetype=F) +
  # theme_test() +
  # facet_wrap(~ topic) +
  labs(x = 'Period', y = 'Prevalence', title='Politics')

# extract the legend from one of the plots
legend <- get_legend(
  # create some space to the left of the legend
  p1 + theme(legend.box.margin = margin(0, 0, 0, 12))
)
legend_b <- get_legend(
  p1 + 
    guides(color = guide_legend(nrow = 1)) +
    theme(legend.position = "bottom")
)
# add the legend to the row we made earlier. Give it one-third of 
# the width of one plot (via rel_widths).
p <- plot_grid(prow, legend, rel_widths = c(3, .4))
p <- plot_grid(legend_b, prow, ncol= 1, rel_heights = c(.1, 1))
ggsave2(filename = 'ideo_category_period.png', plot = p, units = 'cm', dpi = 'retina', height = 25, width = 25)
