# Author: Ken Zeng 
# Generate word correlation matrix from twitter text 
# and then use hierachal clustering to generate clusters
# https://uc-r.github.io/word_relationships 

library(widyr)
library(tidyverse)
library(tidytext)
library(igraph)
library(ggraph)
library(readr)
library(ggplot2)
library(grid)
library(NbClust)
library(ggwordcloud)
library(readr)
require(data.table)

# replace with your own dataset 
twitter <- fread("texas_election_2018.csv", header=TRUE) 

# clean tweets of all apostrophes 
twitter$cleaned_text <- twitter$tweet_text %>%
  tolower() %>% 
  str_replace_all("\n", "") %>%
  str_replace_all("—", " ") %>% 
  str_replace_all("[^\\u0000-\\u007F]", "") %>%
  str_replace_all("https://t\\.co.*", "") %>% # remove all links? 
  str_replace_all("&amp;", "") %>% # what does this line do? 
  str_replace_all("@", "") %>% # how should we handle mentions? 
  str_replace_all("[[:punct:]]", "") 

# break the tweets down to words 
words_df <- twitter %>% 
  filter(is.na(retweet_tweetid)) %>% 
  unnest_tokens(word, cleaned_text) %>%
  filter(!word %in% stop_words$word)

# identify 2000 most frequent words
top_words <- words_df %>% 
  count(word, sort=TRUE) %>% 
  top_n(2000)

# get word correlation 
word_cor <- words_df %>% 
  inner_join(top_words, by=c("word")) %>% 
  group_by(word) %>% 
  pairwise_cor(word, tweetid) %>% 
  filter(!is.na(correlation))


################################################################################
# Naive method: set cutoff and generate graph from all correlations above cutoff
################################################################################


# generate correlation graph object  
cor_graph <- word_cor %>% 
  arrange(desc(correlation)) %>% 
  top_n(3000) %>% 
  select(item1, item2) %>% 
  graph_from_data_frame() 

# label each node with the frequency of the word 
sizes <- as.data.frame(V(cor_graph)$name) %>% 
  inner_join(top_words, by = c("V(cor_graph)$name" = "word"))
V(cor_graph)$n <- sizes$n

cor_plot <- ggraph(cor_graph, layout = "kk") +   # force repel layout 
  geom_edge_link(alpha = 0.4, color = "steelblue3") +
  geom_node_point(aes(size=sizes$n), alpha = 0.5, color = "steelblue3") + 
  geom_node_text(aes(label = name, size=sizes$n), vjust = 0.1, 
                 hjust = 0.1,  colour = "grey99") + 
  theme(legend.position="none", panel.background = element_rect(fill= "grey0"))


# there's a super big connected component in the graph. Let's take a look at that 
largest_cluster <- decompose(cor_graph,  min.vertices = 25)[[1]]

ggraph(largest_cluster, layout = "kk") +   # force repel layout 
  geom_edge_link(alpha = 0.4, color = "steelblue3") +
  geom_node_point(aes(), alpha = 0.5, color = "steelblue3") + 
  geom_node_text(aes(label = name), vjust = 0.1, 
                 hjust = 0.1,  colour = "grey99") + 
  theme(legend.position="none", panel.background = element_rect(fill= "grey0"))


# identify words in the connected components 
cliques(cor_graph, min=2)

# at the moment, we can group together words with the highest correlation 
# how do we repell 

# save the plot 
ggsave(filename = "word_correlation.png", cor_plot, width = 5, height = 5, dpi=300)

################################################################################
# Hierachal Clustering on correlation matrix 
################################################################################

# change the word correlation dataframe to a matrix 
vals<-sort(unique(c(as.character(word_cor$item1), as.character(word_cor$item2))))
cor_matrix<-matrix(-1, nrow=length(vals), ncol=length(vals), dimnames=list(vals, vals))
diag(cor_matrix)<-1

# fill the matrix with the pairwise correlations 
cor_matrix[as.matrix(word_cor[, 1:2])] <- as.matrix(word_cor[,3])
cor_matrix[as.matrix(word_cor[, 2:1])] <- as.matrix(word_cor[,3])

# convert correaltion to distance 
cor_dism <- as.dist(1 - nm)
word.tree <- hclust(cor_dism, method="complete")
plot(word.tree, cex = 0.2)

# problem: r plots very slowly 
clusters <- cutree(word.tree, k=10)
table(clusters)

# 

cor_cut_kgap <- cutree(word.tree, 20)
table(cor_cut_kgap)
clusters <- as.data.frame(cor_cut_kgap)


colnames(clusters) <- c('group')
word <- rownames(clusters) 
rownames(clusters) <- NULL
word_clusters <- cbind(word, clusters) %>% 
  inner_join(top_words) 

word_clusters %>% 
  filter(group == 5) %>% 
  arrange(desc(n)) %>% 
  top_n(20)

# what's gt? 

# plot the results of the cluster 
cluster_plot <- word_clusters %>% 
  ggplot(aes(label=word)) + 
    geom_text_wordcloud(aes(label = word, size = n)) +
    facet_wrap(~group)
  
word_plot <- word_clusters %>% 
  arrange(desc(n)) %>%
  top_n(100) %>% 
  ggplot(aes(label=word)) + 
  geom_text_wordcloud(aes(colour=group, size=n))


# https://bio723-class.github.io/Bio723-book/clustering-in-r.html



