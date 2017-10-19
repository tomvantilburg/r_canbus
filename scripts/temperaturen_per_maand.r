require("RPostgreSQL")
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname = "research",
                 host = "localhost", port = 5433,
                 user = "postgres")


df <- dbGetQuery(con, "
                 SELECT signalid, count(*) from canbus.data_2017
                  GROUP BY signalid
                  ORDER BY signalid
                 ")

df <- dbGetQuery(con, "
                 SELECT value speed, vin as auto, signalid, date_part('month', time) as month, date_part('hour', time) as hour from canbus.data_2017
                  WHERE signalid = 13
                 ")


x=0:23
plot(NULL,
     xlim=c(-10,40),
     ylim=c(0,0.1),
     xlab = 'temperatuur (degC)',
     ylab = 'aantal waarnemingen',
     type='o', las=1)

col = rainbow(12, start = 0.3, end = 0.9)

for (month in 1:12){
  df2 = df[df$month == month,]
  if (nrow(df2) > 100){
  lines(density(df2$speed), col=col[month])
  }
}

