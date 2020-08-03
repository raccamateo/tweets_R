# Text Mining de tweets -> R

install.packages(c("rtweet", "quanteda", "readtext", "spacyr", "quanteda.textmodels", "newsmap", "tidyverse", "tidytext", "igraph", "ggraph", "stopwords", "widyr"))

library(tidyverse)
library (rtweet)
library(quanteda)
library(readtext)
library(spacyr)
library(quanteda.textmodels)
library(newsmap)
library(tidytext)
library(igraph)
library(ggraph)
library(tidyverse)
library(stopwords)
library(widyr)

appname <- "nombre de la app que crearon para obtener las API keys"

>consumer_key <- "lo que aparezca en la parte de consumer key de su app"

>consumer_secret <- "lo que aparezca en la parte de consumer secret de su app"

>access_token <- "lo que aparezca en la parte de access token de su app"

>access_secret <- "lo que aparezca en la parte de access secret de su app"

twitter_token <- create_token(app = appname,
                              consumer_key = consumer_key,
                              consumer_secret = consumer_secret,
                              access_token = access_token,
                              access_secret = access_secret)

Larreta <- search_tweets(q = "Larreta",
                         n = 8000,
                         lang = "es",
                         include_rts = FALSE)

Larreta$stripped_text <- gsub("http.*","",  Larreta$text)
Larreta$stripped_text <- gsub("https.*","", Larreta$stripped_text)

larreta_cleaned <- Larreta %>%
  dplyr::select(stripped_text) %>%
  unnest_tokens(word, stripped_text)

larreta_final <- larreta_cleaned %>%
  anti_join(stopwordslangs)

larreta_final %>%
  count(word, sort = TRUE) %>%
  top_n(15) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(x = word, y = n, fill = n)) +
  geom_col() +
  xlab(NULL) +
  coord_flip() +
  labs(y = "n",
       x = "palabras únicas",
       title = "Palabras únicas más mencionadas en tweets que mencionan a Larreta",
       subtitle = "2020")

larreta_final_paired_words <- Larreta %>%
  dplyr::select(stripped_text) %>%
  unnest_tokens(paired_words, stripped_text, token = "ngrams", n = 2)

larreta_final_separated_words <- larreta_final_paired_words %>%
  separate(paired_words, c("word1", "word2"), sep = " ")

larreta_filtered <- larreta_final_separated_words %>%
  filter(!word1 %in% stop_words$word) %>%
  filter(!word2 %in% stop_words$word)


larreta_words_counts %>%
  filter(n >= 90) %>%
  graph_from_data_frame() %>%
  ggraph(layout = "fr") +
  geom_node_point(color = "darkslategray4", size = 3) +
  geom_node_text(aes(label = name), vjust = 1.8, size = 3) +
  labs(title = "Word Network: tweets que mencionan a Larreta",
       subtitle = "Text mining con R",
       x = "", y = "")

#Por último, agradecer al post de Antonio Vázquez Brust (https://rpubs.com/HAVB/rtweet) que fue mi puerta de entrada, y una guía súper útil.
