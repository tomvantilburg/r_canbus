## aantal waarneming per uur voor verschillende dagen

require("RPostgreSQL")
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname = "research",
                 host = "metis", port = 5433,
                 user = "postgres")


df <- dbGetQuery(con, "
                 SELECT value speed, 
                 vin as auto, 
                 signalid, 
                 date_part('dow', time) as day, 
                 date_part('hour', time) as time
                 FROM canbus.data_2017 
                 WHERE time > '2017-04-01'
                 ")
dbDisconnect(con)

col = c('grey', 'green', 'black', 'black', 'black', 'blue', 'grey')
x=0:23
plot(NULL,
     xlim=c(0,24),
     ylim=c(0,100000),
     xlab = 'tijdstip (uur)',
     ylab = 'aantal waarnemingen',
     type='o', las=1)

#col = c('grey',rep('black',5),
#                    'grey')
dagen=c('zo', 'ma', '', '', '', 'vr', 'za')
for (day in 0:6){
  df2 = df[df$day == day,]
  a = hist(df2$time,breaks = x, plot=F)
  lines(a$mids,a$counts,col=col[day+1], lwd=1)
  #text(x = a$mids[9], y = a$counts[9], labels = dagen[day+1], pos=3, offset = c(0,0.5), cex = 0.8)
}
legend(x='topleft', legend=c('weekend','doordeweeks'),col=c('grey', 'black'), lty=1, inset=0.02)

