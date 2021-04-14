#################################
#######################################################
# plot network - 2 categories 
### similar to visualize-network.R, this takes the tidygraph output of qdata-semantic-net-2-categories-alt
# and plots a series of network graphs (only two)

# but there's a slightly different "filter" for the top nodes here. b/c we want a nice 
# distribution of top nodes from cat1 and cat2 both, as well as edges that connect them
# all. 

# I don't really know how to make a one-size-fits-all chart.  We ideally want to run the loop of top nodes
# and top edges until we've distilled the network down to 100-200 'most important' networks.
# there are prefashioned loops to do just that -- usually by computing the 'center' -- but
# we want something simple that essentially just calls for the 'maximum" points and "maximum" 
# edges, whatever that means.
#cat1 <- "nations"
#cat2 <- "office"
library(foreach)
library(tidyverse)
library(readxl)
library(lubridate)
library(itertools)
library(dplyr)
library(tibble)
library(doParallel)
library(igraph)
library(ggraph)
library(tidygraph)

setwd("~/projects/data")
edges <- read_csv(paste0(cat1, "-", cat2, "-", target, "-edges.csv"))
nodes <- read_csv(paste0(cat1, "-", cat2, "-", target, "-nodes.csv"))
gendescription <- paste0(stringr::str_to_title(cat1), " and ", stringr::str_to_title(cat2))
gen_classifier <- gen_classifier()
nodes <- nodes %>% left_join(gen_classifier) %>%
  filter(kind %in% c(cat1, cat2))

set.seed(1)


# filter for top categories
top50cat1 <- nodes %>% 
  #anti_join(stop_words, by = c("node" = "word")) %>% # remove with updated data
  filter(kind == cat1) %>% arrange(desc(count)) %>%
  dplyr::top_n(50, wt = count)
top50cat2 <- nodes %>% filter(kind == cat2) %>% 
  arrange(desc(count)) %>%
  #anti_join(stop_words, by = c("node" = "word")) %>%  # remove with updated data
  dplyr::top_n(50, wt = count)
top100 <- rbind(top50cat1, top50cat2)
cat1edges <- edges %>% select(to, from, from_name, to_name, weight) %>%
  inner_join(top50cat1, by = c("to" = "id")) %>%
  select(to, from, from_name, to_name,  weight) %>%
  inner_join(top50cat2, by = c("from" = "id")) %>%
  select(to, from, from_name, to_name, weight) %>%
  filter(to != from) %>%
  dplyr::top_n(70, wt = weight)
cat2edges <- edges %>% select(to, from, from_name, to_name, weight) %>%
  inner_join(top50cat2, by = c("to" = "id")) %>%
  select(to, from, from_name, to_name,  weight) %>%
  inner_join(top50cat1, by = c("from" = "id")) %>%
  select(to, from, from_name, to_name, weight) %>%
  filter(to != from) %>%
  dplyr::top_n(70, wt = weight)
tope <- rbind(cat1edges, cat2edges) 


top100again <- top100 %>% filter((id %in% tope$to) | (id %in% tope$from)) 
tope <- tope %>% filter(from %in% top100again$id) %>% filter(to %in% top100again$id) 

#renumber
top100again <- top100again %>%
  mutate(id = row_number()) %>%
  filter(!is.na(node))

tope1 <- tope%>% select(-to, -from) %>%
 inner_join(top100again, by=c("from_name" = "node")) %>%
  rename("from" = "id") %>% 
  select(-count, -connections, -kind, - cat, -empire, -geography)


tope2 <- tope1 %>%  
  left_join(top100again, by=c("to_name" = "node")) %>%
  rename("to" = "id") %>%
  select(-count, -connections, -kind, - cat, -empire, -geography)
# %>%
  #select(to, from, to_name, from_name, weight) #"to", "from", "to_name", "from_name", "weight")

#  # select(to, from, to_name, from_name, weight) %>%
  # select(-nation1, -nation2) %>%
  # select(-count) 
  
if(nrow(top100again) > 5){
k <- min(top100$count)
w <- min(tope2$weight)

ig1 <- graph_from_data_frame(d = tope2, vertices = top100again, directed = FALSE)
tidygraph2 <- as_tbl_graph(ig1)


g21 <- tidygraph2 %>%
   filter(!node_is_isolated())# %>%
  # mutate(neighbors = centrality_degree()) %>%
  # arrange(-neighbors) %>%
  # filter(neighbors > 0)

ggraph(g21, layout = "nicely") + # fr or lgl or graphopt or nicely
  geom_edge_fan(aes(width = weight), alpha = 0.05) +
  geom_node_point(aes(size = count, alpha = 1, color = kind)) +
  geom_node_text(aes(label = name, size = count, alpha = 1), repel = FALSE) +
  theme_void()+
  labs(title = paste0(stringr::str_to_title(gendescription), " with more than ", k, " mentions and ", w, " edges"), 
       subtitle = paste0("Data: ", gendescription, " names co-located in ", target_description), 
       caption = "Data: Britain's parliamentary debates according to Hansard, 1803-1911")



setwd(vizfolder)
ggsave(paste("top_of_each_category_top_edges",  gendescription, "-", target_description, Sys.time(),".pdf"),
       h = 6, w = 6, units = "in", dpi = 1500)

}else{
  
  # make network
  ig1 <- graph_from_data_frame(d = edges, vertices = nodes, directed = FALSE)
  tidygraph1 <- tbl_graph(nodes = nodes, edges = edges, directed = FALSE)
  
  tidygraph1 <- tidygraph1 %>% bind_nodes(nodes)
  tidygraph1
  
  g21 <- tidygraph1 %>%
    filter(!node_is_isolated())
  
  ggraph(g21, layout = "fr") + # fr or lgl or graphopt or nicely
    geom_edge_fan(aes(width = weight), alpha = 0.05) +
    geom_node_point(aes(size = weight, alpha = 1, color = kind)) +
    geom_node_text(aes(label = node, size = weight, alpha = 1), repel = FALSE) +
    theme_void()+
    labs(title = paste0(stringr::str_to_title(gendescription), " with more than ", k, " mentions and ", w, " edges"), 
         subtitle = paste0("Data: ", gendescription, " names co-located in ", target_description), 
         caption = "Data: Britain's parliamentary debates according to Hansard, 1803-1911")
  
  
  
  setwd("~/projects/visualizations")
  ggsave(paste("top_of_each_category_top_edges",  gendescription, "-", target_description, Sys.time(),".pdf"),
         h = 6, w = 6, units = "in", dpi = 1500)
}
# focus on nodes not in britain

nonbritain <- nodes %>%
  filter(geography != "Britain") %>%
  filter((kind == "nations")|(kind == "cities")) %>%
  arrange(desc(count)) 
top50cat12 <- nonbritain %>% filter(kind == cat1) %>% arrange(desc(count)) %>%
  dplyr::top_n(500, wt = count)
top50cat22 <- nodes %>% 
  anti_join(stop_words, by = c("node" = "word")) %>%  # remove with updated data
  filter(kind == cat2) %>% arrange(desc(count)) %>%
  dplyr::top_n(50, wt = count)
top1002 <- rbind(top50cat12, top50cat22) %>%
  mutate(id = row_number()) %>%
  filter(!is.na(node))


cat1edges2 <- edges %>% select(-to, -from) %>%
  inner_join(top50cat12, by = c("to_name" = "node")) %>%
  dplyr::rename("to" = "id") %>%
  select(-count, -connections, -kind, - cat, -empire, -geography) %>%
  inner_join(top50cat22, by = c("from_name" = "node")) %>%
  dplyr::rename(from = id) %>% 
  select(-count, -connections, -kind, - cat, -empire, -geography) %>%
  filter(to != from) %>%
  dplyr::top_n(100, wt = weight)

cat2edges2 <- edges %>% select(-to, -from) %>%
  inner_join(top50cat22, by = c("to_name" = "node"))  %>%
  rename("to" = "id") %>%
  select(-count, -connections, -kind, - cat, -empire, -geography) %>%
  inner_join(top50cat12, by = c("from_name" = "node")) %>%
  rename("from" = "id") %>% 
  select(-count, -connections, -kind, - cat, -empire, -geography) %>%
  filter(to != from) %>%
  dplyr::top_n(100, wt = weight)

tope2 <- rbind(cat1edges2, cat2edges2) 
#top100again2 <- top1002 %>% filter((id %in% tope2$to) | (id %in% tope2$from))
#tope2 <- tope2 %>% filter(from %in% top100again2$id) %>% filter(to %in% top100again2$id) 

ig3 <- graph_from_data_frame(d = tope2, vertices = top1002, directed = FALSE)
tidygraph3 <- as_tbl_graph(ig3)

if(nrow(top100again2) > 5){
  
k <- max(top100again2$count)
w <- max(tope2$weight)

g3 <- tidygraph3 %>%
  filter(!node_is_isolated()) %>%
  mutate(neighbors = centrality_degree()) %>%
  arrange(-neighbors) %>%
  filter(neighbors > 0)

ggraph(g3, layout = "nicely") + # fr or lgl or graphopt or nicely
  geom_edge_fan(aes(width = weight), alpha = 0.03) +
  geom_node_point(aes(size = count, alpha = 1, color = kind)) +
  #geom_edge_fan(alpha = 0.1) +
  geom_node_text(aes(label = name, size = count, alpha = 1), repel = FALSE) +
  theme_void()+
  labs(title = paste0(stringr::str_to_title(gendescription), " with more than ", k, " mentions and ", w, " edges"), 
       subtitle = paste0("Data: ", gendescription, " names co-located in ", target_description), 
       caption = "Data: Britain's parliamentary debates according to Hansard, 1803-1911")

setwd("~/projects/visualizations")
ggsave(paste("nonbritain_top_of_each_category_top_edges",  gendescription, "-", gendescription2, "-", target_description, Sys.time(),".pdf"),
       h = 6, w = 6, units = "in", dpi = 1500)

}
