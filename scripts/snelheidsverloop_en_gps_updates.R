require("RPostgreSQL")

drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname = "research",
                 host = "localhost", port = 5433,
                 user = "postgres")

q <- "  
SELECT  vin, 
min(time) as min_time, 
max(time) as max_time, 
COUNT(*) as count, 
min(value) min_v, 
max(value) as max_v, 
EXTRACT(EPOCH FROM (min(time) - LAG(min(time), 1) OVER(PARTITION BY vin ORDER BY min(time) ))) dt,
geom 
FROM  canbus.data_2017
WHERE signalid = 191 AND 
vin = '807940e893267994237dfc53cf9c1f4a3f9985a41f65e7de9b15f65a7d08aabd' 
GROUP BY vin, geom
ORDER BY vin, min_time; "

df <- dbGetQuery(con, q)

# speed values of same vehicle
r <- " SELECT time, value FROM canbus.data_2017 
WHERE vin = '807940e893267994237dfc53cf9c1f4a3f9985a41f65e7de9b15f65a7d08aabd' AND signalid = 191
ORDER BY time"

ef <- dbGetQuery(con, r)

close(zz)

dbDisconnect(con)

df$min_time = as.POSIXct(df$min_time)
df$max_time = as.POSIXct(df$max_time)
datum = as.Date(df$min_time[1])

plot(range(df$min_time), 
     range(df$dt, na.rm=T), 
     type='n', 
     xaxt='n',
     xlab = 'time',
     ylab = 'time between points (s) / speed (km/h)',
     ylim=c(0,150),
     xlim=c(as.numeric(as.POSIXct(paste(datum,"13:07:00"))), as.numeric(as.POSIXct(paste(datum,"13:34")))),
     las=1,
     cex.lab=1, cex.axis=0.8)
r <- as.POSIXct(round(range(as.POSIXct(df$min_time)), "mins"))
abline(v=seq(r[1], r[2], by = "1 min"), col='lightgrey', lty=4, h=seq(0,150,10))

df = merge(x = df, y = ef, by.x = 'min_time', by.y = 'time', all.x = T)
#points(df$min_time, df$value, type='p', col=2, lwd=2)
lines(df$min_time, df$dt, type='h', col=2, lwd=2)

axis.POSIXct(1, at = seq(r[1], r[2], by = "1 min"), format = "%H:%M", cex.axis=0.6)
legend(x='topleft', 
       legend = c('speed (km/h)', 'time between gps updates (s)'), col=c(1, 2), lty=c(1,1), lwd=c(1,2),pch=c(16,NA), cex=.6, inset=c(.02), xpd=NA)
lines(ef$time, ef$value, type='o', col=1, pch=16, cex=0.5)


