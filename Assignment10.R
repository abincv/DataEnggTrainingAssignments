
# Import Library
library(ggplot2)
library(dplyr)
library(lubridate)
library(tidyr)
library(DT)
library(ggthemes)
library(wordcloud)
library(stringr)




## Explore & Read Uber NYC Trip data for year 2014
USvideos <- read.csv("C:/Users/ASUS/Desktop/aaa/USvideos.csv",strip.white = TRUE,sep = ',')
INvideos <- read.csv("C:/Users/ASUS/Desktop/aaa/INvideos.csv",strip.white = TRUE,sep = ',')
GBvideos <- read.csv("C:/Users/ASUS/Desktop/aaa/GBvideos.csv",strip.white = TRUE,sep = ',')
FRvideos <- read.csv("C:/Users/ASUS/Desktop/aaa/FRvideos.csv",strip.white = TRUE,sep = ',')
CAvideos <- read.csv("C:/Users/ASUS/Desktop/aaa/CAvideos.csv",strip.white = TRUE,sep = ',')


## row wise concatination of records
videos <- rbind(USvideos,INvideos,GBvideos,FRvideos,CAvideos)

#videos$trending_date
#videos$publish_time
#videos
videos$trending_date <- as.Date(videos$trending_date,"%y.%d.%m")
videos$publish_time <- ymd_hms(paste(substr(videos$publish_time, start = 0, stop = 10),substr(videos$publish_time, start = 12, stop = 19)))

Encoding(videos$title) <- "UTF-8"
Encoding(videos$channel_title) <- "UTF-8"
Encoding(videos$tags) <- "UTF-8"

#class(videos)
#str(videos)

sapply(videos,class)

#b. Display the correlation plot between category_id, views, likes, dislikes, comment_count. Which two have stronger and weaker correlation

#c. Display Top 10 most viewed videos of YouTube.----------------------------------------------------

#top_n(videos, 10, views)  

# mostviewed <- head(videos %>%
#   group_by(video_id,title) %>%
#   dplyr::summarise(Total_views = sum(views)) %>%
#   arrange(desc(Total_views)),10)
# 
# datatable(mostviewed)

mostviewed <- head(videos %>%
      group_by(video_id,title) %>%
      dplyr::summarise(Total_views = max(views)) %>%
      arrange(desc(Total_views)) ,10)

datatable(mostviewed)

ggplot(mostviewed, aes(Total_views, title)) +
  geom_bar( stat = "identity", fill = "blue") +
  scale_y_discrete(labels = function(y) str_wrap(y, width = 25)) +
  ggtitle("Top 10 most viewed videos of YouTube.")


#d.Show Top 10 most liked videos on YouTube.--------------------------------------------------------
# mostliked <- head(videos %>%
#                      group_by(video_id,title) %>%
#                      dplyr::summarise(Total_likes = sum(likes)) %>%
#                      arrange(desc(Total_likes)),10) 
# 
# datatable(mostliked)

mostliked <- head(videos %>%
      group_by(video_id,title) %>%
      dplyr::summarise(Total_likes = max(likes)) %>%
      arrange(desc(Total_likes)) ,10)


datatable(mostliked)

ggplot(mostliked, aes(Total_likes, title)) +
  geom_bar( stat = "identity", fill = "red") +
  scale_y_discrete(labels = function(y) str_wrap(y, width = 25)) +
  ggtitle("Top 10 most liked videos of YouTube.")


#e. Show Top 10 most disliked videos on YouTube.------------------------------------------------------

# mostdisliked <- head(videos %>%
#                     group_by(video_id,title) %>%
#                     dplyr::summarise(Total_dislikes = sum(dislikes)) %>%
#                     arrange(desc(Total_dislikes)),10) 
# 
# datatable(mostdisliked)

mostdisliked <- head(videos %>%
      group_by(video_id,title) %>%
      dplyr::summarise(Total_dislikes = max(dislikes)) %>%
      arrange(desc(Total_dislikes)) ,10)

datatable(mostdisliked)

ggplot(mostdisliked, aes(Total_dislikes,title )) +
  geom_bar( stat = "identity", fill = "green") +
  scale_y_discrete(labels = function(y) str_wrap(y, width = 25)) +
  ggtitle("Top 10 most disliked videos of YouTube.")

#f. Show Top 10 most commented video of YouTube-------------------------------------------------------


# mostcommented <- head(videos %>%
#                      group_by(video_id,title) %>%
#                      dplyr::summarise(Total_comments = sum(comment_count)) %>%
#                      arrange(desc(Total_comments)),10) 
# 
# datatable(mostcommented)

mostcommented <- head(videos %>%
      group_by(video_id,title) %>%
      dplyr::summarise(Total_comments = max(comment_count)) %>%
      arrange(desc(Total_comments)) ,10)

datatable(mostcommented)

ggplot(mostcommented, aes(Total_comments,title )) +
  geom_bar( stat = "identity", fill = "black") +
  scale_y_discrete(labels = function(y) str_wrap(y, width = 25)) +
  ggtitle("Top 10 most commented videos of YouTube.")


#g. Show Top 15 videos with maximum percentage (%) of Likes on basis of views on video.----------------------


max_percent_of_likes <- head(videos %>%
                        group_by(video_id,title) %>%
                        dplyr::summarise(percent_of_likes = round (100* max (likes, na.rm = T)/ max (views, na.rm = T), digits = 2)) %>%
                        arrange(desc(percent_of_likes)) ,15)

datatable(max_percent_of_likes)

ggplot(max_percent_of_likes, aes(percent_of_likes,title )) +
  geom_bar( stat = "identity", fill = "pink") +
  scale_y_discrete(labels = function(y) str_wrap(y, width = 30)) +
  ggtitle("Top 15 videos with maximum percentage (%) of Likes on basis of views on video")


#h. Show Top 15 videos with maximum percentage (%) of Dislikes on basis of views on video.-------------------

max_percent_of_dislikes <- head(videos %>%
                               group_by(video_id,title) %>%
                               dplyr::summarise(percent_of_dislikes = round (100* max (dislikes, na.rm = T)/ max (views, na.rm = T), digits = 2)) %>%
                               arrange(desc(percent_of_dislikes)) ,15)

datatable(max_percent_of_dislikes)

ggplot(max_percent_of_dislikes, aes(percent_of_dislikes,title)) +
  geom_bar( stat = "identity", fill = "orange") +
  scale_y_discrete(labels = function(y) str_wrap(y, width = 25)) +
  ggtitle("Top 15 videos with maximum percentage (%) of Dislikes on basis of views on video")

#i. Show Top 15 videos with maximum percentage (%) of Comments on basis of views on video.-------------------

max_percent_of_comments <- head(videos %>%
                                  group_by(video_id,title) %>%
                                  dplyr::summarise(percent_of_comments = round (100* max (comment_count, na.rm = T)/ max (views, na.rm = T), digits = 2)) %>%
                                  arrange(desc(percent_of_comments)) ,15)

datatable(max_percent_of_comments)

ggplot(max_percent_of_comments, aes( percent_of_comments,title)) +
  geom_bar( stat = "identity", fill = "blue") +
  scale_y_discrete(labels = function(y) str_wrap(y, width = 25)) +
  ggtitle("Top 15 videos with maximum percentage (%) of comments on basis of views on video")

#j. Top trending YouTube channels in all countries--------------------------------------------------------

trending_channels <- head(videos %>%
                     dplyr::count(channel_title) %>%
                     arrange(desc(n)),10)

datatable(trending_channels)

# plot.new()
# pie(trending_channels$n, trending_channels$channel_title, col = rainbow(5))
# legend("topright",
#        c("setosa","versicolor","virginica"),cex = 0.8, 
#        fill = rainbow(5))

ggplot(trending_channels, aes( n,channel_title)) +
  geom_bar( stat = "identity", fill = "blue") +
  ggtitle("Top 10 trending channels")


#k.Top trending YouTube channels in India.------------------------------------------------------------

trending_channelsIN <- head(INvideos %>%
                            dplyr::count(channel_title) %>%
                            arrange(desc(n)),10)

datatable(trending_channelsIN)


ggplot(trending_channelsIN, aes(n,channel_title)) +
  geom_bar( stat = "identity", fill = "blue") +
  ggtitle("Top 10 trending channels in india")

#l. Create a YouTube Title WordCloud.----------------------------------------------------------------


library(tm)
library(SnowballC)
library(RColorBrewer)

text <- head(videos$tags,10000)
  
docs <- Corpus(VectorSource(text))
inspect(docs)

toSpace <- content_transformer(function (x , pattern ) gsub(pattern, " ", x))
docs <- tm_map(docs, toSpace, "/")
docs <- tm_map(docs, toSpace, "@")
docs <- tm_map(docs, toSpace, "\\|")

# Remove english common stopwords
docs <- tm_map(docs, removeWords, stopwords("english"))
docs <- tm_map(docs, removeWords, c("the", "is","how"))

dtm <- TermDocumentMatrix(docs)
m <- as.matrix(dtm)
v <- sort(rowSums(m),decreasing=TRUE)
d <- data.frame(word = names(v),freq=v)
head(d, 10)

set.seed(1234)
wordcloud(words = d$word, freq = d$freq, min.freq = 1,
          max.words=200, random.order=FALSE, rot.per=0.35, 
          colors=brewer.pal(8, "Dark2"))

#m. Show Top Category ID------------------------------------------------------------------------------
topcategory <- head( videos %>%
                    dplyr::count(category_id) %>%
                    arrange(desc(n)),1)

datatable(topcategory)

# n. How much time passes between published and trending?---------------------------------------------

timedifference <- videos %>%
                  dplyr::summarise(Mean=mean(difftime(as.POSIXct(videos$trending_date,"UTC"),videos$publish_time,units = "hours")))
                  

datatable(timedifference)



# o. Show the relationship plots between Views Vs. Likes on Youtube.-----------------------------------

ggplot(videos, aes(x=views, y=likes)) + geom_point()

#p. Top Countries In total number of Views in absolute numbers------------------------------------------

INviews <- INvideos %>%
           group_by(video_id) %>%
           dplyr::summarise(Total = max(views)) %>%
           dplyr::summarise(Total_views = sum(Total))

USviews <- USvideos %>%
  group_by(video_id) %>%
  dplyr::summarise(Total = max(views)) %>%
  dplyr::summarise(Total_views = sum(Total))

GBviews <- GBvideos %>%
  group_by(video_id) %>%
  dplyr::summarise(Total = max(views)) %>%
  dplyr::summarise(Total_views = sum(Total))

FRviews <- FRvideos %>%
  group_by(video_id) %>%
  dplyr::summarise(Total = max(views)) %>%
  dplyr::summarise(Total_views = sum(Total))

CAviews <- CAvideos %>%
  group_by(video_id) %>%
  dplyr::summarise(Total = max(views)) %>%
  dplyr::summarise(Total_views = sum(Total))

country <- c("IN","US","GB","FR","CA")

views <- cbind(rbind(INviews,USviews,GBviews,FRviews,CAviews),country) %>%
          arrange(desc(Total_views))

datatable(views)


# q. Top Countries In total number of Likes in absolute numbers

INlikes <- INvideos %>%
  group_by(video_id) %>%
  dplyr::summarise(Total = max(likes)) %>%
  dplyr::summarise(Total_likes = sum(Total))

USlikes <- USvideos %>%
  group_by(video_id) %>%
  dplyr::summarise(Total = max(likes)) %>%
  dplyr::summarise(Total_likes = sum(Total))

GBlikes <- GBvideos %>%
  group_by(video_id) %>%
  dplyr::summarise(Total = max(likes)) %>%
  dplyr::summarise(Total_likes = sum(Total))

FRlikes <- FRvideos %>%
  group_by(video_id) %>%
  dplyr::summarise(Total = max(likes)) %>%
  dplyr::summarise(Total_likes = sum(Total))

CAlikes <- CAvideos %>%
  group_by(video_id) %>%
  dplyr::summarise(Total = max(likes)) %>%
  dplyr::summarise(Total_likes = sum(Total))


likes <- cbind(rbind(INlikes,USlikes,GBlikes,FRlikes,CAlikes),country) %>%
  arrange(desc(Total_likes))

datatable(likes)

# r. Top Countries In total number of Dislikes in absolute numbers

INdislikes <- INvideos %>%
  group_by(video_id) %>%
  dplyr::summarise(Total = max(dislikes)) %>%
  dplyr::summarise(Total_dislikes = sum(Total))

USdislikes <- USvideos %>%
  group_by(video_id) %>%
  dplyr::summarise(Total = max(dislikes)) %>%
  dplyr::summarise(Total_dislikes = sum(Total))

GBdislikes <- GBvideos %>%
  group_by(video_id) %>%
  dplyr::summarise(Total = max(dislikes)) %>%
  dplyr::summarise(Total_dislikes = sum(Total))

FRdislikes <- FRvideos %>%
  group_by(video_id) %>%
  dplyr::summarise(Total = max(dislikes)) %>%
  dplyr::summarise(Total_dislikes = sum(Total))

CAdislikes <- CAvideos %>%
  group_by(video_id) %>%
  dplyr::summarise(Total = max(dislikes)) %>%
  dplyr::summarise(Total_dislikes = sum(Total))


dislikes <- cbind(rbind(INdislikes,USdislikes,GBdislikes,FRdislikes,CAdislikes),country) %>%
  arrange(desc(Total_dislikes))

datatable(dislikes)

# s. Top Countries In total number of Comments in absolute numbers

INcomment_count <- INvideos %>%
  group_by(video_id) %>%
  dplyr::summarise(Total = max(comment_count)) %>%
  dplyr::summarise(Total_comment_count = sum(Total))

UScomment_count <- USvideos %>%
  group_by(video_id) %>%
  dplyr::summarise(Total = max(comment_count)) %>%
  dplyr::summarise(Total_comment_count = sum(Total))

GBcomment_count <- GBvideos %>%
  group_by(video_id) %>%
  dplyr::summarise(Total = max(comment_count)) %>%
  dplyr::summarise(Total_comment_count = sum(Total))

FRcomment_count <- FRvideos %>%
  group_by(video_id) %>%
  dplyr::summarise(Total = max(comment_count)) %>%
  dplyr::summarise(Total_comment_count = sum(Total))

CAcomment_count <- CAvideos %>%
  group_by(video_id) %>%
  dplyr::summarise(Total = max(comment_count)) %>%
  dplyr::summarise(Total_comment_count = sum(Total))


comment_count <- cbind(rbind(INcomment_count,UScomment_count,GBcomment_count,FRcomment_count,CAcomment_count),country) %>%
  arrange(desc(Total_comment_count))

datatable(comment_count)


# t. Title length words Frequency Distribution-------------------------------------------------

qq <- videos %>%
  dplyr::summarise(len = nchar(title))


ggplot(qq, aes(len)) +
  geom_histogram(bins = 20, color="darkblue", fill="lightblue") +
  ggtitle("Distribution of length of title")
