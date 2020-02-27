# Author: Ken Zeng 
# Analyze the group of users who made the tweet 
# Texas has a choice to make I choosecruz 

library(tidyverse)
library(tidytext)
library(igraph)
library(ggraph)
library(readr)
library(ggplot2)
library(grid)
library(stringr)

# load cleaned text and then remove duplicate tweets 
filtered_twitter <- read.csv("tx_cleaned.csv") %>% 
  group_by(tweetid) %>% 
  slice(1) %>% 
  ungroup()

# identify subset we are interested in
twitter_subset <- filtered_twitter %>% 
  filter(str_detect(cleaned_text, 
                    "texas has a choice to make and i choosecruz because tedcruz has texas booming while betoorourke will take our state backwards watch and retweet keeptexasred texasdebate"))

# identify all unqiue users 
names.rt <- twitter_subset %>% select(retweet_user_screen_name) 
names.og <- twitter_subset %>% filter(is.na(retweet_tweetid)) %>% select(user_screen_name)
names <- unique(c(as.character(names.rt$retweet_user_screen_name), 
                  as.character(names.og$user_screen_name)))
names<- names[names != ""]
names.df <- as.data.frame(list("user_screen_name"=names)) 

# look at all the tweets 
selected_tweets <- filtered_twitter %>% 
  filter(user_screen_name %in% names.df$user_screen_name | retweet_user_screen_name %in% names.df$user_screen_name)

# users who cant be reached by twitter API 
failed = read.csv("failed2.csv", header = FALSE)


retweeted_users = selected_tweets %>% 
  select(retweet_user_screen_name) %>% 
  filter(retweet_user_screen_name !=  "") 

colnames(retweeted_users) <- c("user_screen_name")

tweeted_users = selected_tweets %>% 
  select(user_screen_name)

users = rbind(retweeted_users, tweeted_users) %>% 
  group_by(user_screen_name) %>% 
  count(user_screen_name, sort = TRUE) %>% 
  ungroup() %>% 
  mutate(participant = ifelse(user_screen_name %in% names.df$user_screen_name, 1, 0)) %>%
  mutate(inactive = ifelse(user_screen_name %in% failed$V1,1, 0))

# identify unique edges 
network_edges <- selected_tweets %>% 
  filter(retweet_user_screen_name != "") %>%
  group_by(user_screen_name, retweet_user_screen_name) %>% 
  count(sort = TRUE) %>% 
  ungroup()

# identify the ids of all the users who made original tweets
original_ids = selected_tweets %>% 
  select(user_screen_name, userid)

# identify the ids of all the users who has been retweeted 
retweet_ids = selected_tweets %>% 
  select(retweet_user_screen_name, retweet_userid)
colnames(retweet_ids) <- c("user_screen_name", "userid")

# combine the retweet and original ids 
ids = rbind(retweet_ids, original_ids) %>% 
  group_by(user_screen_name) %>%
  slice(1) %>% ungroup()

# we only want to display the names of the top 
nodes <- users %>% 
  left_join(ids, by.x = "user_screen_name", 
            by.y = "user_screen_name") %>% 
  mutate(user_screen_name = ifelse(n >= 200, 
                                   as.character(user_screen_name), 
                                   rep(" ", dim(users)[1])))
colnames(nodes) <- c('Label', 'n', 'participant', 'inactive', 'Id')

# retwrite the edge format to 
edges = network_edges %>% 
  left_join(ids) %>% 
  rename(Source=userid) %>%
  left_join(ids, by = c("retweet_user_screen_name"="user_screen_name")) %>%
  rename(Target=userid)

topics = c(
  "president|trump|potus", 
  "38|million|381", 
  "caravan|migrant|immigrant", 
  "cuts|tax", 
  "social|security", 
  "town|hall", 
  "crazy|liberal|screaming", 
  "2a|amendment|defend"
)

topics = c(
  "38|million|381", 
  "caravan|migrant|immigrant|crossing", 
  "cuts|tax", 
  "social|security", 
  "town|hall", 
  "crazy|liberal|screaming", 
  "2a|amendment|defend"
)

edge_by_topic <- selected_tweets %>% 
  filter(retweet_user_screen_name != "") %>% 
  mutate(topic = length(topics) + 1)

for (i in 1:length(topics)) {
  edge_by_topic <- edge_by_topic %>% 
    mutate(topic = ifelse(str_detect(cleaned_text, topics[i]), i, topic))
}

edge_by_topic %>% 
  group_by(retweet_userid, userid) %>% 
  slice(1) 

labelled_edges = edges %>% 
  left_join(edge_by_topic %>% 
              group_by(retweet_userid, userid) %>% slice(1), 
            by = c("retweet_user_screen_name"="retweet_user_screen_name", 
                   "user_screen_name" = "user_screen_name"))

# save results as csv 
names.df %>% write.csv("names_1.csv")
labelled_edges %>% write.csv("labelled_edges.csv")
nodes %>% write.csv("nodes_1.csv")


  


  


