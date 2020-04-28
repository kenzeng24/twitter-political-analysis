
library(tidytext)
library(tidyverse)
library(ggplot2)
library(tidyverse)
library(ggraph)
library(igraph)

# twitter is your tweet csv 
# troll_tweets is the subset of twitter that is made by trolls
# make sure it has columns: retweet_user_screen_name, user_screen_name, tweet_text
twitter <- read.csv("texas_election_2018.csv")

# identify the most retweeted users in the dataset 
influential_users <- twitter %>% 
  filter(!is.na(retweet_user_screen_name)) %>% 
  group_by(retweet_user_screen_name) %>% 
  count(sort =TRUE) %>% 
  ungroup() %>% 
  top_n(500) %>% 
  mutate(is.troll = ifelse(retweet_user_screen_name %in% troll_tweets$user_screen_name, 1, 0))

# identify links between the influential users
influential_network <- twitter %>% 
  filter(retweet_user_screen_name %in% influential_users$retweet_user_screen_name) %>% 
  filter(user_screen_name %in% influential_users$retweet_user_screen_name)

# identify trollbots
network_edges <- influential_network %>% 
  group_by(user_screen_name, retweet_user_screen_name) %>% 
  count(sort = TRUE) %>% 
  ungroup() %>% 
  mutate(troll_edge = ifelse(user_screen_name %in% troll_tweets$user_screen_name | 
                               retweet_user_screen_name %in% troll_tweets$user_screen_name, 1,0))

# remove self retweeting edges: yes there are people who retweeted themselves 
twitter_graph <- network_edges %>% 
  filter(user_screen_name != retweet_user_screen_name) %>% 
  graph_from_data_frame(vert = influential_users)

# filters largest connected component 
largest_component <- decompose(twitter_graph, min.vertices = 200)[[1]]

# normal users are blue, bots are red 
social_graph_with_bots <- ggraph(largest_component, layout = "kk") +
  geom_edge_diagonal(aes(color=as.factor(troll_edge)), alpha = 0.4) +
  scale_color_manual(values = c("steelblue", "indianred3")) +
  scale_edge_color_manual(values = c("steelblue3", "lightcoral")) + 
  geom_node_point(aes(size = n, color=as.factor(is.troll)), alpha= 0.5) +
  geom_node_text(aes(label = name, size = n), hjust=0.1, vjust=0.1, colour = "grey99", check_overlap = TRUE) + 
  theme(legend.position="none", panel.background = element_rect(fill= "grey0")) 

# generate tweet_retweet plot 
social_graph <- ggraph(largest_component, layout = "kk") +
  geom_edge_diagonal(aes(color=as.factor(troll_edge)), alpha = 0.4, colour ="steelblue") +
  geom_node_point(aes(size = n), alpha= 0.5, colour = "steelblue3") +
  geom_node_text(aes(label = name, size = n), hjust=0.1, vjust=0.1, colour = "grey99", check_overlap = TRUE) + 
  theme(legend.position="none", panel.background = element_rect(fill= "grey0"))

# we can use these to save plots with the desired resolution 
ggsave(filename = "tweet_retweet_network.png", social_graph,  width = 20, height = 12, dpi = 500)
ggsave(filename = "tweet_retweet_network_with_bots.png", social_graph_with_bots,  width = 20, height = 12, dpi = 500)


### How to generate clusters

adjacency <- as.matrix(as_adjacency_matrix(largest_component))
layout <- layout_with_fr(largest_component)
twitter_clusters <- cluster_edge_betweenness(as.undirected(largest_component))

V(largest_component)$group <- twitter_clusters$membership

ggraph(largest_component, layout = "kk") +
  geom_edge_diagonal(color = "grey39", alpha = 0.3) +
  scale_color_manual(values = c("steelblue", "indianred3", "purple", "pink", "green", "orange", "brown")) +
  geom_node_point(aes(size = n, color=as.factor(group))) +
  geom_node_text(aes(label = name, size = n), hjust=0.1, vjust=0.1, colour = "grey99", check_overlap = TRUE) +
  theme(legend.position="none", panel.background = element_rect(fill= "grey0")) 


### Group by modularity 

modularity_clusters <- cluster_fast_greedy(as.undirected(largest_component))
V(largest_component)$modularity <- modularity_clusters$membership

ggraph(largest_component, layout = "kk") +
  geom_edge_diagonal(color = "grey39", alpha = 0.3) +
  scale_color_manual(values = c("steelblue", "indianred3", "purple", "pink", "green", "orange", "brown", "grey")) +
  geom_node_point(aes(size = n, color=as.factor(modularity))) +
  geom_node_text(aes(label = name, size = n), hjust=0.1, vjust=0.1, colour = "grey99", check_overlap = TRUE) +
  theme(legend.position="none", panel.background = element_rect(fill= "grey0")) 

optimal_clusters <- cluster_optimal(as.undirected(largest_component))
V(largest_component)$clusters <- optimal_clusters$membership

ggraph(largest_component, layout = "kk") +
  geom_edge_diagonal(color = "grey39", alpha = 0.3) +
  scale_color_manual(values = c("steelblue", "indianred3", "purple", "pink", "green", "orange", "brown", "grey")) +
  geom_node_point(aes(size = n, color=as.factor(clusters))) +
  geom_node_text(aes(label = name, size = n), hjust=0.1, vjust=0.1, colour = "grey99", check_overlap = TRUE) +
  theme(legend.position="none", panel.background = element_rect(fill= "grey0")) 






  
  








