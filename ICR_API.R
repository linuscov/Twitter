library(readxl)
library(tidyverse)
library(peRspective)
library(tidycomm)
#run ICR
fullsample <- read_excel("full.sample.all.manual.coding.xlsx")

icr_result <- test_icr(data = fullsample,
                       na.omit = F,
                       unit_var = status_id,
                       coder_var = coder,
                       "toxicity", 
                       "insult",
                       "identity",
                       fleiss_kappa = T)

#FINAL 
tweets200 <- read_excel("toxic.tweets.fullsmpl.xlsx")

tweets200$status_id <- as.numeric(tweets200$status_id) 

tweets200_manual <- read_excel("combined.coding.xlsx")

tweets200_manual <- tweets200_manual %>% 
    rename(toxicity_manual = toxicity, insult_manual = insult, identity_attack_manual = identity)

#remove punctuation
tweets200 %>%
  str_replace_all("[:punct:]", "")

#run it through perspective
tweets200_api <- tweets200 %>% 
  prsp_stream(text = text,
              text_id = status_id,
              languages = "en",
              score_model = c("TOXICITY", "INSULT", "IDENTITY_ATTACK"),
              key = "AIzaSyA--oRHleCT5fmSJiPnmxj0EH8m6n_dcQg")

#rename column
tweets200_api <- tweets200_api %>% 
  rename(status_id = text_id)

tweets200_api$status_id <- as.numeric(tweets200_api$status_id) 

tweets200_api_score <- tweets200_api %>% 
  mutate(toxicity_api = case_when(TOXICITY >= 0.7 ~ 1, TOXICITY < 0.7 ~ 0)) %>% 
  mutate(insult_api = case_when(INSULT >= 0.7 ~ 1, INSULT < 0.7 ~ 0)) %>% 
  mutate(identity_attack_api = case_when(IDENTITY_ATTACK >= 0.7 ~ 1, IDENTITY_ATTACK < 0.7 ~ 0))

#rejoin with main dataframe
tweets200_scored <- inner_join(tweets200, tweets200_api_score, by = "status_id")
tweets200_scored_manual <- inner_join(tweets200_manual, tweets200_scored, by = "status_id")

#save
write.csv(tweets200_scored, "fullsmpl.api.scores.csv")
write.csv(tweets200_scored_manual, "fullsmpl.api.manual.csv")
