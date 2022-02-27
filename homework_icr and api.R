#run ICR
icr <- read_excel("Tweets_coded.xlsx")


icr_result <- test_icr(data = icr,
                       unit_var = text,
                       coder_var = Coder,
                       "incivility", 
                       "intolerance",
                       fleiss_kappa = T)

icr_result

write.csv(icr_result, "icr_results.csv")

#running tweets through perspective api
nz_tweets <- read_excel("tweets_sample.xlsx")

persp_nz_tweets <- nz_tweets %>% 
  prsp_stream(text = text,
              text_id = status_id,
              languages = "en",
              score_model = c("TOXICITY", "SEVERE_TOXICITY"),
              key = "AIzaSyA--oRHleCT5fmSJiPnmxj0EH8m6n_dcQg", by ="status_id")

#rename column
persp_nz_tweets <- persp_nz_tweets %>% 
  rename(status_id = text_id)

#rejoin with main dataframe
nz_tweets_coded <- inner_join(icr, persp_nz_tweets)
nz_tweets_api <- inner_join(nz_tweets, persp_nz_tweets)

#save
write.csv(nz_tweets_coded, "tweets coded with api.csv")
write.csv(nz_tweets_api, "tweets api.csv")