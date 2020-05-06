# TwitterClustering
===================================

In 2018, the Texas Senate election had its closest margin of victory in over 40 years [1]. This election gained a lot of national attention due to various issues surrounding the two candidates: Beto O’Rourke on the Democrat side and Ted Cruz on the Republican side. While there was a third candidate (Neal Dikeman, Libertation), analysis of his results have been omitted. Consequently, this project analyzes tweets from users throughout the country in order to gain insights on popular topics surrounding the election, how these topics varied across demographics, and how users were engaging with each other in the context of the election.

## Data
------------

The main dataset for this project was a dataset of tweets discussing the election. This dataset covers tweets made during October 12 to November 8. The dataset contains information such the text of the tweet, the username of the user who posted it, the number of retweets and likes this user had, the date their account was created, and so on. This dataset was scraped from the Twitter site. (More information about the variables used can be found on the Twitter API [2].) For this project, the dataset was cleaned by removing hyperlinks within the tweets, mentions of other users, emoticon Unicode, and other foreign characters that remained in the text. This was done to make sure that tweets were within the 280 character limit.

## References
--------------
- vitek, Patrick, and Abby Livingston. “How the Race between Ted Cruz and Beto O’Rourke Became the Closest in Texas in 40 Years.”" The Texas Tribune, The Texas Tribune, 9 Nov. 2018, www.texastribune.org/2018/11/09/ted-cruz-beto-orourke-closest-texas-race-40-years/.

- “Docs - Twitter Developers.” Twitter, Twitter, 2019, developer.twitter.com/en/docs.
