
#Currently twitteR_1.1.8.tar.gz and httr_0.6.1.tar.gz required as the latest don't seem to work
tool_exec <- function(in_params, out_prams)
{
  if (!requireNamespace("httr", quietly = TRUE))
    install.packages("httr")
  if (!requireNamespace("twitteR", quietly = TRUE))
    install.packages("twitteR")
  if (!requireNamespace("sp", quietly = TRUE))
      install.packages("sp")
  require(httr)
  require(twitteR)
  require(sp)

  search_term = in_params[[1]]
  consumer_key = in_params[[2]]
  consumer_secret = in_params[[3]]
  access_token = in_params[[4]]
  access_secret = in_params[[5]]
  lat = in_params[[6]]
  lon = in_params[[7]]


  out_tweets = out_prams[[1]]
#Setup authentication
  options(httr_oauth_cache=T)
  setup_twitter_oauth(consumer_key,consumer_secret,access_token,access_secret)
  arc.progress_label("Connection to Twitter API Made...")

  arc.progress_label("Getting some Tweets...")
  tweets_returned <- twListToDF(searchTwitter(paste(in_params[[1]]), geocode=paste0(lat,",",lon,",10mi")))
  tweets_returned <-   tweets_returned[!is.na(tweets_returned$longitude)& !is.na(tweets_returned$latitude),]
  arc.progress_label("Tweets aquired...")

  arc.progress_label("Creating a Shapefile...")
  tweets_returned_SPDF <- SpatialPointsDataFrame(coords = cbind(as.numeric(tweets_returned$longitude), as.numeric(tweets_returned$latitude)), data = tweets_returned, proj4string = CRS("+init=epsg:4326"))

  arc.write(out_tweets, tweets_returned_SPDF@data,coordinates(tweets_returned_SPDF),list(type='Point', WKT=arc.shapeinfo(tweets_returned_SPDF)$WKT))


}
