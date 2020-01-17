# Author: Ken Zeng 
# Generate word correlation matrix from twitter text 

library(widyr)
library(tidyverse)
library(tidytext)
library(igraph)
library(ggraph)
library(readr)
library(ggplot2)
library(grid)

# replace with your own dataset 
twitter <- read_csv("texas_election_2018.csv") 

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

# plot the result graph 
cor_plot <- ggraph(cor_graph, layout = "fr") +   # force repel layout 
  geom_edge_link(alpha = 0.4, color = "steelblue3") +
  geom_node_point(aes(size=sizes$n), alpha = 0.5, color = "steelblue3") + 
  geom_node_text(aes(label = name, size=sizes$n), vjust = 0.1, 
                 hjust = 0.1,  colour = "grey99") + 
  theme(legend.position="none", panel.background = element_rect(fill= "grey0"))
  
# not the prettiest looking graph 
cor_plot



# there's a super big connected component in the graph. Let's take a look at that 
largest_cluster <- decompose(cor_graph,  min.vertices = 10)[[1]]

ggraph(largest_cluster, layout = "fr") +   # force repel layout 
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
  






