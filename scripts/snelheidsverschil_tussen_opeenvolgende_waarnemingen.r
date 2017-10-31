require("RPostgreSQL")
library("RColorBrewer")
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname = "research",
                 host = "localhost", port = 5433,
                 user = "postgres")


speed <- dbGetQuery(con, "
        SELECT value as speed, 
        value - lag(value) OVER (partition by vin order by vin, time) diff, vin as auto, time, location from canbus.data_2017
          WHERE signalid = 191
")

plot(density(speed$diff, na.rm=T, bw = 1), xlim=c(-20,20))
abline(v=c(-5,0,5), lty=2)