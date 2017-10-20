require("RPostgreSQL")
require("ggplot2")

drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname = "research",
                 host = "localhost", port = 5433,
                 user = "postgres")
df_postgres <- dbGetQuery(con, "
         SELECT location, speed_avg, flow_sum, date, 
          round(date_part('hour',date)) tod
        FROM ndw.trafficspeed_2 
        WHERE location = 'RWS01_MONIBAS_0021hrl0336ra'
      AND date > '2017-10-12' --now() - '7 days'::interval
      AND date < '2017-10-13'
      --AND date_part('dow',date) > 0
")
ggplot(df_postgres,aes(flow_sum,speed_avg, colour = factor(tod))) + geom_point(shape="o") + theme_bw()
e