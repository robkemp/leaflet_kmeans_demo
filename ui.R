library(shiny)
library(shinydashboard)
library(codemog)
library(rgdal)
library(tigris)
library(leaflet)
library(dplyr)
library(tidyr)


dashboardPage(skin="black",
    dashboardHeader(title= "State KMeans Mapper"),
    dashboardSidebar(
      sidebarMenu(
        selectInput("clusters","Cluster Number:",
                    choices=1:30, selected = 5),
        menuItem("GitHub Repo", icon = icon("file-code-o"), 
                 href = "https://github.com/robkemp/leaflet_kmeans_demo"))),
    dashboardBody(fluidRow(tabBox(
                            tabPanel("Median Income and Population K-Means Map",
                              leafletOutput("kmeans_map")),
                            tabPanel("Data and Methods", "State-level Population and Median income from the 2013 ACS 5-year File.
                                  K-means clustering used scaled data and the `kmeans()` call from base R."),
                           width = 12,
                           height = 12))
    )
)

