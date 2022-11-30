library(ggplot2)
data('searchK_metoo.RData')

Kplot <- list()

Kplot[[1]] <- ggplot(searchK_metoo$results, aes(x=K, y=semcoh)) +
  geom_line() +
  # ggforce::geom_bspline0() +
  geom_point(aes(40,searchK_metoo$results$semcoh[searchK_metoo$results$K == 40]), 
             size=3, colour='firebrick') +
  geom_smooth(colour = 'grey', se = 0) +
  # theme_bw(base_size = 15) +
  theme_linedraw(base_size = 15) +
  labs(x='Number of Topics (K)', y='Sementic Coherence', title='Sementic Coherence')
Kplot[[2]] <- ggplot(searchK_metoo$results, aes(K, heldout)) +
  geom_line() +
  geom_point(aes(40,searchK_metoo$results$heldout[searchK_metoo$results$K == 40]), 
             size=3, colour='firebrick') +
  geom_smooth(colour = 'grey', se = 0) +
  # theme_bw(base_size = 15) +
  theme_linedraw(base_size = 15) +  
  labs(x='Number of Topics (K)', y='Heldout Likelihood', title='Heldout Likelihood')
Kplot[[3]] <- ggplot(searchK_metoo$results, aes(K, exclus)) +
  geom_line() +
  geom_point(aes(40,searchK_metoo$results$exclus[searchK_metoo$results$K == 40]), 
             size=3, colour='firebrick') +
  geom_smooth(colour = 'grey', se = 0) +
  # theme_bw(base_size = 15) +
  theme_linedraw(base_size = 15) +  
  labs(x='Number of Topics (K)', y='Exclusivity', title='Exclusivity')

Kplot_grid <- grid.arrange(grobs=Kplot, ncol = 3)

# ggsave2(plot = Kplot_grid, filename = 'SearchKPlot.png', dpi = 'retina',
#         width = 10, height = 4)
