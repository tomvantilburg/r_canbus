# temperatuurverdeling per maand vanaf april 2017

require("RPostgreSQL")
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname = "research",
                 host = "metis", port = 5433,
                 user = "postgres")

df <- dbGetQuery(con, "
                 SELECT value speed, vin as auto, signalid, date_part('month', time) as month, date_part('hour', time) as hour from canbus.data_2017
                  WHERE signalid = 13 AND time > '2017-04-01'
                 ")
dbDisconnect(con)

x=0:23
plot(NULL,
     xlim=c(-10,50),
     ylim=c(0,0.15),
     xlab = 'temperature (degC)',
     ylab = 'density',
     type='o', las=1)

months = unique(df$month)
col = rainbow(length(months), start = 0.3, end = 0.9)

for (month in sort(months)){
  df2 = df[df$month == month,]
  if (nrow(df2) > 100){
  lines(density(df2$speed), col=col[which(months == month)])
  }
}
legend(x='topleft', legend = months, col = col, lty=1, inset=0.02, title = 'month #')
abline(v=0, lty=3)

