#### VISUALIZE NETWORK

# this code begins with the tidygraph1, nodes, and edges objects created in 
# qdata-semantic-network-alt.R
# It produces a seris of hopefully lucid visualizations

# DEVELOPMENT
# 1) Probably this script should be run in advance to spit out static csv's for major targets 
# (city-concern, nation-concern, concern-office, etc.).  Perhaps the graph visualization 
# should also be pre-computed.  There's a launcher script in quanteda-code-for-app-2.R, but
# perhaps it needs additions, for example if g21 should be precomputed before being
# graphed, or if it should begin with the csv files saved towards the end of this script?  
# What is the best kind of architecture?
# 2) please review the "nonbritain" search for g22. the goal is to map nodes whose geography 
# is not Britain.  
# 3) as is, this code is called by both qdata-semantic-net-alt.R and qdata-semantic-net-2-categories-alt.R.
# does it work for both?

# load data
setwd("~/projects/data")
edges <- read_csv(paste0(cat1,"-", target, "-edges.csv"))
nodes <- read_csv(paste0(cat1, "-", target, "-nodes.csv"))

# make network
#ig1 <- graph_from_data_frame(d = edges, vertices = nodes, directed = FALSE)
tidygraph1 <- tbl_graph(nodes = nodes, edges = edges, directed = FALSE)

set.seed(1)

top100 <- nodes %>% arrange(desc(connections)) %>%
  dplyr::top_n(300, wt = connections) %>%
  select(id, node, connections)
tope <- edges %>% select(to, from, weight) %>%
  dplyr::inner_join(top100, by = c("to" = "id")) %>%
  rename(to_name = node) %>%
  select(to, from, weight, to_name) %>%
  dplyr::inner_join(top100, by = c("from" = "id")) %>%
  rename(from_name = node) %>%
  filter(to != from) %>%
  dplyr::top_n(200, wt = weight)
w <- min(tope$weight)
k <- min(top100$connections)


g21 <- tidygraph1 %>%
  activate(edges) %>%
  filter(weight > w) %>%
  activate(nodes) %>%
  filter(connections > k) %>% 
  filter(!node_is_isolated()) %>%
  mutate(neighbors = centrality_degree()) %>%
  arrange(-neighbors) %>%
  filter(neighbors > 1)

ggraph(g21, layout = "nicely") + # fr or lgl or graphopt or nicely
  geom_edge_fan(aes(width = weight), alpha = 0.05) +
  geom_node_point(aes(size = connections, alpha = .8))+#, color = geography)) +
  #geom_edge_fan(alpha = 0.1) +
  geom_node_text(aes(label = node, size = connections, alpha = 1), repel = FALSE) +
  theme_void()+
  labs(title = paste0(stringr::str_to_title(gendescription), " with more than ", k, " mentions and ", w, " edges"), 
       subtitle = paste0("Data: ", gendescription, " names co-located in ", target_description), 
       caption = "Data: Britain's parliamentary debates according to Hansard, 1803-1911")

#'ed by steph setwd(vizfolder)
#'ed by steph ggsave(paste("more_than_", k, "_mentions_and_", w, "_edges_network",  gendescription, "-", target_description, Sys.time(),".pdf"),
#'ed by steph       h = 6, w = 6, units = "in", dpi = 1500)

# focus on nodes not in britain
g22 <- tidygraph1 %>% 
  activate(nodes) %>%
  filter(geography != "Britain") %>%
  filter(!node_is_isolated())

top100 <- nodes %>% 
  filter(geography != "Britain") %>%
  ungroup() %>%
  select(id, count) %>%
  arrange(desc(count)) %>%
  slice(seq_len(200)) 

top3 <- edges %>% 
  filter(to != from) %>%
  inner_join(top100, by = c("to" = "id")) %>%
  inner_join(top100, by = c("from" = "id"))  %>%
  arrange(desc(weight)) %>%
  slice(seq_len(200))

w <- min(top100$count)
k <- min(top3$weight)

g222 <- g22 %>%
  activate(edges) %>%
  filter(weight > k) %>%
  activate(nodes) %>%
  filter(count > w) %>% 
  filter(!node_is_isolated())  %>%
  mutate(neighbors = centrality_degree()) %>%
  arrange(-neighbors) %>%
  filter(neighbors > 2)

ggraph(g222, layout = "fr") + # fr or lgl or graphopt or nicely
  geom_edge_fan(aes(width = weight), alpha = 0.05) +
  geom_node_point(aes(size = count, alpha = 1, color = geography)) +
  #geom_edge_fan(alpha = 0.1) +
  geom_node_text(aes(label = node, size = count, alpha = 1), repel = FALSE) +
  theme_void() +
  labs(title = paste0(stringr::str_to_title(gendescription), " outside of Britain with more than ", k, " mentions and ", w, " edges"), 
       subtitle = paste0("Data: ", gendescription, " names co-located in ", target_description), 
       caption = "Data: Britain's parliamentary debates according to Hansard, 1803-1911")

#'ed by steph setwd(vizfolder)
#'ed by steph ggsave(paste("not_britain_more_than_", k, "_mentions_and_", w, "_edges_for_network_", gendescription, "-", target_description,Sys.time(),".pdf"),
#'ed by steph       h = 6, w = 6, units = "in", dpi = 1500)


# 
# 
# #traveling salesman algorithm
# 
# g25 <- tidygraph1 %>%
#   activate(nodes) %>% 
#   mutate(n_rank_trv = node_rank_traveller()) %>% # Minimize hamiltonian path length using a travelling salesperson solver.
#   filter(n_rank_trv > .90*max(n_rank_trv))%>%
#   filter(!node_is_isolated())  %>%
#   mutate(neighbors = centrality_degree()) %>%
#   arrange(-neighbors) %>%
#   filter(neighbors > 2)
# 
# ggraph(g25, layout = "fr") + # fr or lgl or graphopt or nicely
#   geom_edge_link(alpha = 0.1, aes(width = weight)) +
#   geom_node_point(aes(size = count, alpha = 1, color = geography)) +
#   #geom_edge_fan(alpha = 0.1) +
#   geom_node_text(aes(label = node, size = count, alpha = 1), repel = FALSE) +
#   theme_void() +
#   labs(title = paste0(stringr::str_to_title(gendescription), " whose connections are minimized by Hamiltonian distance/traveling salesperson algorithm"), 
#        subtitle = paste0("Data: ", gendescription, " names co-located in ", target_description), 
#        caption = "Data: Britain's parliamentary debates according to Hansard, 1803-1911")
# 
# 
# setwd(vizfolder)
# ggsave(paste("top_traveling_salesperson_",  gendescription, "-", target_description,Sys.time(),".pdf"),
#        h = 6, w = 6, units = "in", dpi = 1500)
# 
# 
# g255 <- tidygraph1 %>%
#   activate(nodes) %>%   filter(geography != "Britain") %>%
#   mutate(n_rank_trv = node_rank_traveller()) %>% # Minimize hamiltonian path length using a travelling salesperson solver.
#   filter(n_rank_trv > .5*max(n_rank_trv))%>%
#   filter(!node_is_isolated())  %>%
#   mutate(neighbors = centrality_degree()) %>%
#   arrange(-neighbors) %>%
#   filter(neighbors > 2)
# 
# ggraph(g255, layout = "fr") + # fr or lgl or graphopt or nicely
#   geom_edge_link(alpha = 0.1, aes(width = weight)) +
#   geom_node_point(aes(size = count, alpha = 1, color = geography)) +
#   #geom_edge_fan(alpha = 0.1) +
#   geom_node_text(aes(label = node, size = count, alpha = 1), repel = FALSE) +
#   theme_void() +
#   labs(title = paste0(stringr::str_to_title(gendescription), " outside Britain whose connections are minimized by Hamiltonian distance/traveling salesperson algorithm"), 
#        subtitle = paste0("Data: ", gendescription, " names co-located in ", target_description), 
#        caption = "Data: Britain's parliamentary debates according to Hansard, 1803-1911")
# 
# 
# setwd(vizfolder)
# ggsave(paste("outside_britain_top_traveling_salesperson_",  gendescription, "-", target_description,Sys.time(),".pdf"),
#        h = 6, w = 6, units = "in", dpi = 1500)
# 
# 
# # work with betweenness and centrality
# # g3 <- tidygraph1 %>%
# #   activate(nodes) %>%
# #   mutate(centrality = centrality_authority())  %>%
# #   mutate(node_betweenness = centrality_betweenness()) %>%
# #   # mutate(center = node_is_center()) %>%
# #   # arrange(desc(centrality_betweenness())) %>%
# #   filter(node_betweenness > (max(node_betweenness)*.5))# %>%
# # 
# # ggraph(g3, layout = "fr") + # fr or lgl or graphopt
# #   geom_edge_fan(aes(width = weight), alpha = 0.03) +
# #   geom_node_point(aes(size = centrality, color = geography, alpha = centrality)) +
# #   #geom_edge_fan(alpha = 0.1) +
# #   geom_node_text(aes(label = node, size = count, alpha = 0.5), repel = TRUE) +
# #   theme_void() +
# #   labs(title = paste0(stringr::str_to_title(gendescription), " by top centrality betweenness"), 
# #        subtitle = paste0("Data: ", gendescription, " names co-located in ", target_description), 
# #        caption = "Data: Britain's parliamentary debates according to Hansard, 1803-1911")
# # 
# # 
# # ggsave(paste("network_w_max_centrality_betweenness", gendescription, "-", target_description,Sys.time(),".pdf"),
# #        h = 6, w = 6, units = "in", dpi = 1500)
# 
# 
# g35 <- tidygraph1 %>%
#   activate(nodes) %>%
#   filter(geography != "Britain") %>%
#   mutate(centrality = centrality_authority())  %>%
#   mutate(node_betweenness = centrality_betweenness()) %>%
#   # mutate(center = node_is_center()) %>%
#   # arrange(desc(centrality_betweenness())) %>%
#   filter(node_betweenness > (max(node_betweenness)*.3))# %>%
# 
# ggraph(g35, layout = "fr") + # fr or lgl or graphopt
#   geom_edge_fan(aes(width = weight), alpha = 0.03) +
#   geom_node_point(aes(size = centrality, color = geography, alpha = centrality)) +
#   #geom_edge_fan(alpha = 0.1) +
#   geom_node_text(aes(label = node, size = count, alpha = 0.5), repel = TRUE) +
#   theme_void() +
#   labs(title = paste0(stringr::str_to_title(gendescription), " outside Britain by top centrality betweenness"), 
#        subtitle = paste0("Data: ", gendescription, " names co-located in ", target_description), 
#        caption = "Data: Britain's parliamentary debates according to Hansard, 1803-1911")
# 
# ggsave(paste("network_outsside_britain_w_max_centrality_betweenness", gendescription, "-", target_description,Sys.time(),".pdf"),
#        h = 6, w = 6, units = "in", dpi = 1500)
# 
# # 
# # 
# # g36 <- tidygraph1 %>%
# #   activate(nodes) %>% 
# #   mutate(neighbors = centrality_degree()) %>%
# #   arrange(-neighbors) %>%
# #   filter(neighbors > .8*(max(neighbors)))
# # 
# # g36 
# # 
# # ggraph(g36, layout = "fr") + # fr or lgl or graphopt
# #   geom_edge_fan(aes(width = weight), alpha = 0.02) +
# #   geom_node_point(aes(size = count, color = geography), alpha = 0.2) +
# #   #geom_edge_fan(alpha = 0.1) +
# #   geom_node_text(aes(label = node, size = count), repel = FALSE) +
# #   theme_void() +
# #   labs(title = paste0("Which ", gendescription, " have the most neighbors?"), 
# #        subtitle = paste0("Data: ", gendescription, " names co-located in ", target_description), 
# #        caption = "Data: Britain's parliamentary debates according to Hansard, 1803-1911")
# # 
# # ggsave(paste("top_neighbors_network_w_neighbors", gendescription, "-", target_description,Sys.time(),".pdf"),
# #        h = 6, w = 6, units = "in", dpi = 1500)
# 
# 
# 
# g37 <- 
#   tidygraph1 %>%  filter(geography != "Britain") %>%
#   filter(!node_is_isolated()) %>%
#   activate(nodes) %>% 
#   mutate(neighbors = centrality_degree()) %>%
#   arrange(-neighbors) %>%
#   filter(neighbors > .8*(max(neighbors)))
# 
# 
# 
# ggraph(g37, layout = "fr") + # fr or lgl or graphopt
#   geom_edge_fan(aes(width = weight), alpha = 0.02) +
#   geom_node_point(aes(size = count, color = geography), alpha = 0.2) +
#   #geom_edge_fan(alpha = 0.1) +
#   geom_node_text(aes(label = node, size = count), repel = FALSE) +
#   theme_void() +
#   labs(title = paste0("Which ", gendescription, " outside Britain have the most neighbors?"), 
#        subtitle = paste0("Data: ", gendescription, " names co-located in ", target_description), 
#        caption = "Data: Britain's parliamentary debates according to Hansard, 1803-1911")
# 
# ggsave(paste("top_neighbors_network_outside_britain_w_neighbors", gendescription, "-", target_description,Sys.time(),".pdf"),
#        h = 6, w = 6, units = "in", dpi = 1500)
# 
# g38 <-  tidygraph1 %>%  filter(geography != "Britain") %>%
#   filter(geography != "Europe") %>%
#   filter(!node_is_isolated()) %>%
#   activate(nodes) %>% 
#   mutate(neighbors = centrality_degree()) %>%
#   arrange(-neighbors) %>%
#   filter(neighbors > .5*(max(neighbors)))
# 
# 
# ggraph(g38, layout = "fr") + # fr or lgl or graphopt
#   geom_edge_fan(aes(width = weight), alpha = 0.02) +
#   geom_node_point(aes(size = count, color = geography), alpha = 0.2) +
#   #geom_edge_fan(alpha = 0.1) +
#   geom_node_text(aes(label = node, size = count), repel = FALSE) +
#   theme_void() +
#   labs(title = paste0("Which ", gendescription, " outside Britain or Europe have the most neighbors?"), 
#        subtitle = paste0("Data: ", gendescription, " names co-located in ", target_description), 
#        caption = "Data: Britain's parliamentary debates according to Hansard, 1803-1911")
# 
# ggsave(paste("top_neighbors_network_outside_britain_or_europe_w_neighbors", gendescription, "-", target_description,Sys.time(),".pdf"),
#        h = 6, w = 6, units = "in", dpi = 1500)
# 
# # work with edge betweenness
# g5 <- tidygraph1 %>%
#   activate(edges) %>%
#   mutate(edge_betweenness = centrality_edge_betweenness()) %>%
#   arrange(desc(edge_betweenness)) %>%
#   filter(edge_betweenness > .9*max(edge_betweenness))
# 
# ggraph(g5, layout = "graphopt") + # fr or lgl or graphopt
#   geom_edge_link(aes(width = edge_betweenness, color = "lightgray"), alpha = 0.1) +
#   geom_node_point(aes(size = count, color = geography), alpha = 0.2) +
#   #geom_edge_fan(alpha = 0.1) +
#   geom_node_text(aes(label = node, alpha = 0.5), repel = FALSE) +
#   theme_void()+
#   labs(title = paste0("Which ", gendescription," have the greatest edge betweenness?"), 
#        subtitle = paste0("Data: ", gendescription, " names co-located in ", target_description), 
#        caption = "Data: Britain's parliamentary debates according to Hansard, 1803-1911")
# 
# ggsave(paste("top_network_w_edge_betweenness", gendescription, "-", target_description,Sys.time(),".pdf"),
#        h = 6, w = 6, units = "in", dpi = 1500)
# 
# 
# # now with clustering
# g4 <- g22 %>% 
#   activate(nodes) %>%
#   filter(!node_is_isolated()) %>% 
#   top_n(100, wt = count) %>%
#   # mutate(community = as.factor(group_infomap()))
#   #group_optimal, group_label_prop, group_biconnected_component
#   mutate(community = as.factor(group_label_prop())) #%>%
# # %>%
# #  morph(to_unfolded, community) %>%
# #  mutate(group_centrality = centrality_pagerank()) %>%
# #  unmorph
# 
# ggraph(g4, layout = "fr") + # fr or lgl or graphopt
#   #geom_edge_link(alpha = 0.1, color = "lightgray") +
#   geom_node_point(aes(color = community, size = count), 
#                   alpha = 0.4) +
#   geom_edge_fan(alpha = 0.05)+
#   geom_node_text(aes(label = node, size = .75*count
#   ), alpha = .5, repel = FALSE) +
#   theme_void()
# 
# ggsave(paste("community_network_",  gendescription, "-", target_description,".pdf"),
#        h = 6, w = 6, units = "in", dpi = 1500)
# 
