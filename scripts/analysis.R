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
ggplot(df_postgres,aes(date,vehicles)) + geom_line(color="steelblue") + theme_bw()


#Types of measurements
df_postgres <- dbGetQuery(con, "
  SELECT b.name, count(a.signalid) n
  FROM canbus.data_2017 a
  INNER JOIN canbus.signals b
  ON a.signalid = b.signalid
  WHERE time > '2017-03-19'
  GROUP BY b.name
  ORDER BY b.name
")
ggplot(df_postgres, aes(x=name, y=n)) +
  geom_bar(stat='identity',fill='steelblue') +
  coord_flip() + theme_minimal()

#histogram of number of speed measurements per geom
df_postgres <- dbGetQuery(con, "
  WITH grouped AS (
    SELECT geom,count(geom) n
    FROM canbus.data_2017 
    WHERE signalid = 191 
    AND value > 10
    AND time > '2017-03-19'
    GROUP BY geom
  )
  SELECT n, count(geom) freq
  FROM grouped
  GROUP BY n
  ORDER BY n
")
ggplot(data=df_postgres, aes(x=n, y=freq)) +
  geom_bar(stat="identity", fill="steelblue") +
  labs(title="Number of speedmeasurements per GPS point", 
       x="#-measurements", y = "occurance") +
  theme_minimal()


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
  scale_fill_gradient2("Measurement\nDensity", low = "white", mid = "yellow", high = "red", midpoint = 0.25)

#Heatmap of foglight measurements
df_postgres <- dbGetQuery(con, "
  SELECT DISTINCT round(ST_X(geom)::numeric,2) lon, round(ST_Y(geom)::numeric,2) lat
  FROM canbus.data_2017 
  WHERE time > '2017-03-19' AND (signalid = '100' OR signalid = '170')
  
")
ggplot(df_postgres,aes(date,vehicles)) + geom_line() + theme_bw()
qmplot(lon, lat, data = df_postgres, geom = "blank", zoom = 7, maptype = "toner-background", darken = .7, legend = "topright") +
  stat_density_2d(aes(fill = ..level..), geom = "polygon", alpha = .3, color = NA) +
  scale_fill_gradient2("Measurement\nDensity", low = "white", mid = "yellow", high = "red", midpoint = 0.25)


#Heatmap of wiper measurements
df_postgres <- dbGetQuery(con, "
  SELECT DISTINCT round(ST_X(geom)::numeric,2) lon, round(ST_Y(geom)::numeric,2) lat
  FROM canbus.data_2017 
  WHERE time > '2017-03-19' AND (signalid >= 253)
  
")
ggplot(df_postgres,aes(date,vehicles)) + geom_line() + theme_bw()
qmplot(lon, lat, data = df_postgres, geom = "blank", zoom = 7, maptype = "toner-background", darken = .7, legend = "topright") +
  stat_density_2d(aes(fill = ..level..), geom = "polygon", alpha = .3, color = NA) +
  scale_fill_gradient2("Measurement\nDensity", low = "white", mid = "yellow", high = "red", midpoint = 0.25)


#Heatmap of startpoints
df_postgres <- dbGetQuery(con, "
WITH ordered AS (
  SELECT *
    FROM canbus.data_2017  
  WHERE time > '2017-03-19'
  ORDER BY vin, time
)
SELECT
vin,date_trunc('day',time), 
round(ST_X(first(geom))::numeric,4) lon,
round(ST_Y(first(geom))::numeric,4) lat
FROM ordered
GROUP BY vin, date_trunc('day',time);
")
ggplot(df_postgres,aes(date,vehicles)) + geom_line() + theme_bw()
qmplot(lon, lat, data = df_postgres, geom = "blank", zoom = 7, maptype = "toner-background", darken = .7, legend = "topright") +
  stat_density_2d(aes(fill = ..level..), geom = "polygon", alpha = .3, color = NA) +
  scale_fill_gradient2("Measurements\nPropensity", low = "white", mid = "yellow", high = "red", midpoint = 0.25)
