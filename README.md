# tweets_R

# Text Mining de tweets -> R
**Capturar o extraer tweets usando R es relativamente sencillo. Ahora, al momento de analizar tweets en español, el idioma puede volver las cosas algo confusas (al menos para mí lo fueron).**

Hay varias formas de extraer o capturar tweets. Se puede hacer en tiempo real, o no y sobre palabras (o temas), usuarixs o hashtags.

*Supongamos que queremos buscar 15k tweets que mencionen a Larreta.*

Lo primero que **necesitamos** es **tener acceso a las API keys de Twitter**, para lo que necesitamos una cuenta de desarrolladores. Pueden encontrar el paso a paso a paso para crearla y tener los permisos [acá] (https://towardsdatascience.com/access-data-from-twitter-api-using-r-and-or-python-b8ac342d3efe).

Una vez que tenemos la cuenta, hay que **instalar** algunas **librerías en R**.

```R
install.packages(c("rtweet", "quanteda", "readtext", "spacyr", "quanteda.textmodels", "newsmap", "tidyverse", "tidytext", "igraph", "ggraph", "stopwords", "widyr"))
``` 

Una vez que instalamos (solo se instalan una vez) las librerías, **debemos cargarlas, esto se hace cada vez que reincidamos sesión en R, y sólo cuando realmente vamos a usarlas**

``` R
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
``` 

Ahora, debemos crear el token para tener acceso y poder descargar los tweets. Para eso:

``` R
appname <- "nombre de la app que crearon para obtener las API keys"

>consumer_key <- "lo que aparezca en la parte de consumer key de su app"

>consumer_secret <- "lo que aparezca en la parte de consumer secret de su app"

>access_token <- "lo que aparezca en la parte de access token de su app"

>access_secret <- "lo que aparezca en la parte de access secret de su app" 
``` 

*Una vez que completan lo anterior, crean el token propiamente dicho ?)*

``` R
twitter_token <- create_token(app = appname, 
consumer_key = consumer_key, 
consumer_secret = consumer_secret, 
access_token = access_token, 
access_secret = access_secret)
``` 

Ahora vamos a crear el data frame y a descargar los tweets. En este caso, el data frame original se va a llamar Larreta, vamos a extraer 15.000 tweets, en Español y no vamos a incluir retweets.

*Para eso:*

``` R
Larreta <- search_tweets(q = "Larreta", 
n = 8000,
lang = "es", 
include_rts = FALSE)
``` 

***Si bien en el ejemplo se usa "Larreta" (porque es el término a buscar y es más simple para que no nos confundamos) ustedes pueden cambiar todas las variables que están acá.***

Una vez que tenemos la data, podemos pasar a la parte de procesamiento. 
Lo primero que vamos a hacer es limpiar los "http." y "https."

``` R
Larreta$stripped_text <- gsub("http.*","",  Larreta$text)
Larreta$stripped_text <- gsub("https.*","", Larreta$stripped_text)
``` 

El próximo paso asigna a los tweets identidades únicas, convierte todas las letras en minúsculas y elimina las puntuaciones.

``` R
larreta_cleaned <- Larreta %>%
  dplyr::select(stripped_text) %>%
  unnest_tokens(word, stripped_text)
``` 

Ahora vamos a usar ***stop_words*** y ***anti_join*** para quitar palabras que no tienen sentido para el análisis que vamos a realizar.

```R
larreta_final <- larreta_cleaned %>%
  anti_join(stopwordslangs)
```

Ahora podemos graficar para ver lo que hicimos

```R
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
```

Ahora bien, si buscamos relaciones entre palabras, y ver cuáles fueron las cadenas de (n) palabras más usadas y cómo se relacionan las palabras más repetidas podemos usar. 
Para trabajar sobre las secuencias de 2 palabras más usadas debemos ejecutar

```R
larreta_final_paired_words <- Larreta %>%
  dplyr::select(stripped_text) %>%
  unnest_tokens(paired_words, stripped_text, token = "ngrams", n = 2)

>larreta_final_separated_words <- larreta_final_paired_words %>%
  separate(paired_words, c("word1", "word2"), sep = " ")

>larreta_filtered <- larreta_final_separated_words %>%
  filter(!word1 %in% stop_words$word) %>%
  filter(!word2 %in% stop_words$word)
  ```

Ahora bien, en caso de querer hacerlo con 3 palabras consecutivas se reemplaza a n=2 por n=3 y se agrega word3 tanto cuando usamos c(w1,w2) como cuando filtramos.

*Al momento de graficar, hay que considerar la cantidad de tweets con la que trabajamos, ya que en base a eso y al número de palabras consecutivas vamos a tener mejores o peores resultados en la visualización.*

Un ejemplo podría ser

``` R
larreta_words_counts %>%
  filter(n >= 90) %>%
  graph_from_data_frame() %>%
  ggraph(layout = "fr") +
  # geom_edge_link(aes(edge_alpha = n, edge_width = n))
  # geom_edge_link(aes(edge_alpha = n, edge_width = n)) +
  geom_node_point(color = "darkslategray4", size = 3) +
  geom_node_text(aes(label = name), vjust = 1.8, size = 3) +
  labs(title = "Word Network: tweets que mencionan a Larreta",
       subtitle = "Text mining con R",
       x = "", y = "")
       ```

Por último, agradecer al [post de Antonio Vázquez Brust] (https://rpubs.com/HAVB/rtweet) que fue mi puerta de entrada, y una guía súper útil.
