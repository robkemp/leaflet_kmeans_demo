library(shiny)
library(shinydashboard)
library(codemog)
library(rgdal)
library(tigris)
library(leaflet)
library(dplyr)
library(tidyr)


dashboardPage(skin="black",
    dashboardHeader(title= "State KMeans Mapped"),
    dashboardSidebar(
      sidebarMenu(
        selectInput("clusters","Cluster Number:",
                    choices=1:30),
        menuItem("GitHub Repo", icon = icon("file-code-o"), 
                 href = "https://github.com/robkemp/leaflet_kmeans_demo"))),
    dashboardBody(fluidRow(box(title="K-Means Map",
                      leafletOutput("kmeans_map"),
                      width = 12,
                      height = 12)))
    )


