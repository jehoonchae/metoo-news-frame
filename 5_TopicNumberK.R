load('searchK_metoo.RData')
load('searchK_metoo_71.RData')
load('searchK_metoo_trimmed.RData')


dfm_trimmed <- dfm_trim(dfm, max_docfreq = .99, min_docfreq = 0.005, docfreq_type = "prop")

#DFM for stm model
stmdfm <- convert(dfm_trimmed, to = "stm", docvars = docvars(corpus))
out <- prepDocuments(stmdfm$documents, stmdfm$vocab, stmdfm$meta)

# HAVE TO MAKE TYPE AS NUMERIC FOR STM!!!!!!!!
out$meta$press <- as.numeric(out$meta$press)
out$meta$date <- as.numeric(out$meta$date)
out$meta$ideo <- as.numeric(out$meta$ideo)
meta_metoo <- out$meta

# searchK_metoo_trimmed <- searchK(out$documents,
#                                  out$vocab,
#                                  K=c(2:80),
#                                  max.em.its=75,
#                                  prevalence = ~ s(date)*press*ideo,
#                                  data=out$meta)
# save(searchK_metoo_trimmed, file = 'searchK_metoo_trimmed.RData')
# plot(searchK_metoo_trimmed)

held_out <- searchK_metoo_trimmed$results$heldout
exclus <- searchK_metoo_trimmed$results$exclus
semcoh <- searchK_metoo_trimmed$results$semcoh
residual <- searchK_metoo_trimmed$results$residual
num <- c(1: length(held_out)+1)
topicK <- data.frame(num, held_out, exclus, semcoh, residual)

# searchK_metoo <- searchK(out$documents, out$vocab, K=c(2:70),
#                             max.em.its = 75,
#                             prevalence = ~ s(date)*press*ideo,
#                             data=out$meta)
# searchK_metoo_71 <- searchK(out$documents, out$vocab, K=c(71:80),
#                             max.em.its = 75,
#                             prevalence = ~ s(date)*press*ideo,
#                             data=out$meta)
# save(searchK_metoo, file = 'searchK_metoo.RData')
# save(searchK_metoo_71, file = 'searchK_metoo_71.RData')

held_out <- c(searchK_metoo$results$heldout, searchK_metoo_71$results$heldout)
exclus <- c(searchK_metoo$results$exclus, searchK_metoo_71$results$exclus)
semcoh <- c(searchK_metoo$results$semcoh, searchK_metoo_71$results$semcoh)
residual <- c(searchK_metoo$results$residual, searchK_metoo_71$results$residual)
num <- c(1: length(held_out)+1)

topicK <- data.frame(num, held_out, exclus, semcoh, residual)
p1 <- topicK %>% 
  ggplot(aes(x=num, y=held_out)) +
  geom_line() +
  labs(x=NULL, y="Held-out likelihood")

p2 <- topicK %>% 
  ggplot(aes(x=num, y=exclus)) +
  geom_line() +
  labs(x=NULL, y="Exclusivity")

p3 <- topicK %>% 
  ggplot(aes(x=num, y=semcoh)) +
  geom_line() +
  labs(x=NULL, y="Sementic Coherence")
theme_set(theme_bw())
cowplot::plot_grid(p1, p3, p2, ncol=3)
