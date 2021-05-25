# Twitter Political Analysis

In 2018, the Texas Senate election had its closest margin of victory in over 40 years [1]. This election gained a lot of national attention due to various issues surrounding the two candidates: Beto O’Rourke on the Democrat side and Ted Cruz on the Republican side. While there was a third candidate (Neal Dikeman, Libertation), analysis of his results have been omitted. Consequently, this project analyzes tweets from users throughout the country in order to gain insights on popular topics surrounding the election and how users were engaging with each other in the context of the election.

## Data

The main dataset for this project was a dataset of tweets discussing the election. This dataset covers tweets made during October 12 to November 8. The dataset contains information such the text of the tweet, the username of the user who posted it, the number of retweets and likes this user had, the date their account was created, and so on. This dataset was scraped from the Twitter site. (More information about the variables used can be found on the Twitter API [2].) For this project, the dataset was cleaned by removing hyperlinks within the tweets, mentions of other users, emoticon Unicode, and other foreign characters that remained in the text. This was done to make sure that tweets were within the 280 character limit.

## Visualization 

One way to visualize user interaction is through constructing retweet networks; in these networks, each user represents a single node and a directed edge points from the user who made the retweet to the user who made the original tweet. Some of the graphs were generated using igraph, others were processed in R but generated on Gephi. It became apparent that including all users in the social network makes it extremely computationally intensive to plot; in contrast, a network of the top 500 most retweeted users gives a much clearer story of the underlying structure. In most of the generated plots there are two distinct clusters, one centered around Ted Cruz and the other centered around Beto O’Rourke. We expected to see this result, as they were the two primary candidates for this race and thus the center of most of the attention. We also noticed that the two clusters interact much more within themselves than with each other, as there are only a few lines that connect the two clusters. In addition to this, we also retrieved a list of users declared “troll bots” by the bot sentinel website. Interactions from these users are colored red, giving us an interesting insight into the online discussion: 

![Retweet network with bots coloured red](/retweet_networks/tweet_retweet_network.png)

## References

- vitek, Patrick, and Abby Livingston. “How the Race between Ted Cruz and Beto O’Rourke Became the Closest in Texas in 40 Years.”" The Texas Tribune, The Texas Tribune, 9 Nov. 2018, www.texastribune.org/2018/11/09/ted-cruz-beto-orourke-closest-texas-race-40-years/.

- “Docs - Twitter Developers.” Twitter, Twitter, 2019, developer.twitter.com/en/docs.

- https://botsentinel.com/analyzed-accounts/all
