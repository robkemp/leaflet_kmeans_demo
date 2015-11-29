library(codemog)
library(rgdal)
library(tigris)
library(leaflet)
library(dplyr)
library(tidyr)

## Read In Shapefile

dsn=paste(getwd(), "shapefile", sep="/")
s=readOGR(dsn=dsn, layer="tl_2015_us_state")


mhi=codemog_api(datacall = "field", data="b19013001", db="acs0913", sumlev = "40",state="NA", meta="no", geography="sumlev", limit="3500")%>%
  mutate(GEOID=stringr::str_sub(geonum, 2, nchar(as.character(geonum))),
         medianIncome=as.numeric(b19013001))

pop=codemog_api(datacall = "field", data="b01003001", db="acs0913", sumlev = "40",state="NA", meta="no", geography="sumlev", limit="3500")%>%
  mutate(GEOID=stringr::str_sub(geonum, 2, nchar(as.character(geonum))),
         population=as.numeric(b01003001))

data=inner_join(mhi,pop)

clust=data%>%
  select(medianIncome, population)%>%
  scale()

agg=select(data, medianIncome, population)

shinyServer(function(input, output) {

  ## Census Data Download and prepare
  # clust=reactive(get_data(input$data_field))
  
  ## Cluster Analysis data select (only uses numeric variables)
  
  # clust=reactive({format_data(data())})
  
  ## Can use this to pick true # of clusters
  
  wss <- (nrow(clust-1)*sum(apply(clust,2,var)))
  for (i in 2:15) wss[i] <- sum(kmeans(clust,
                                       centers=i)$withinss)
  output$clustPlot=renderPlot({plot(1:15, wss, type="b", xlab="Number of Clusters",
       ylab="Within groups sum of squares")})
  
  # Fit a K-Means Clustering Model using 
  clusters=reactive({input$clusters})
  fit=reactive({kmeans(clust, clusters())})
  
  #check the means of each variable and group
  output$means=reactive({as.data.frame(aggregate(agg,by=list(fit$cluster,FUN=mean)))})
  
  
  ## join clusters back to main data frame
  dbf_clust=reactive({data%>%
    select(GEOID, medianIncome, population)%>%
    bind_cols(data.frame(cluster=fit()$cluster))})
  
  ## join clusters to spatial data
  
  shape=reactive({geo_join(s, dbf_clust(), "GEOID", "GEOID")})
  
  ## set palette
  
  # pal=reactive({colorFactor("Set1", as.factor(shape()$cluster))})
  
  
  ## make popup
  
  popup=reactive({paste0("<strong>Median Income:</strong>", 
               shape()$medianIncome, 
               "<strong>ACS Population:</strong>", 
               shape()$population,
               "<br><strong>Cluster: </strong>", 
               shape()$cluster)})

output$kmeans_map=renderLeaflet({
  pal=colorFactor("Set1", as.factor(shape()$cluster))
  leaflet(shape()) %>%
  clearBounds()%>%
  addProviderTiles("CartoDB.Positron") %>%
  addPolygons(fillColor = ~pal(cluster), 
              fillOpacity = 0.8, 
              color = "#BDBDC3", 
              weight = 1, 
              popup = popup)%>%
  addLegend("bottomright", pal = pal, values = ~cluster,
            title = "K-means Cluster")})
  })

