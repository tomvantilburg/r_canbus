require("RPostgreSQL")
require("ggplot2")
require("hexbin")

drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname = "research",
                 host = "localhost", port = 5433,
                 user = "postgres")
df_postgres <- dbGetQuery(con, "
  SELECT count(DISTINCT vin) vehicles, date_trunc('day',time) date
  FROM canbus.data_2017 
  GROUP BY date_trunc('day',time)
  ORDER BY date_trunc('day',time)
")
#Conclusion: before 19-march id's are switched more then 1x a day
ggplot(df_postgres,aes(date,vehicles)) + geom_line() + theme_bw()

library(ggmap)
nl <- c(left = 3.5, bottom = 50.5, right = 7, top = 53.5)
map <- get_stamenmap(nl, zoom = 7, maptype = "toner-lite")
ggmap(map)




#Heatmap of speedmeasurements
df_postgres <- dbGetQuery(con, "
  SELECT DISTINCT round(ST_X(geom)::numeric,2) lon, round(ST_Y(geom)::numeric,2) lat
  FROM canbus.data_2017 
  WHERE time > '2017-03-19' AND signalid = '191' AND value > 10
  
")
ggplot(df_postgres,aes(date,vehicles)) + geom_line() + theme_bw()
qmplot(lon, lat, data = df_postgres, geom = "blank", zoom = 7, maptype = "toner-background", darken = .7, legend = "topright") +
  stat_density_2d(aes(fill = ..level..), geom = "polygon", alpha = .3, color = NA) +
  scale_fill_gradient2("Measurements\nPropensity", low = "white", mid = "yellow", high = "red", midpoint = 0.25)
