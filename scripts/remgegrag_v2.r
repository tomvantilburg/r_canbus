# positie toevoegen
# naar dataframe

require("RPostgreSQL")

drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname = "research",
                 host = "metis", port = 5433,
                 user = "postgres")

fn = "./scripts/query_braking.sql"
zz <- file(fn, "r")
#q = readLines(zz)
q <- readChar(zz, file.info(fn)$size)
braking <- dbGetQuery(con, q)
close(zz)


speed <- dbGetQuery(con, "
                    SELECT value as speed, vin, time, location from canbus.data_2017
                    WHERE signalid = 191 AND vin = '03662eafcd5b8852e3663484376c027b8b7ea8b30829cae92853ba97d5d63682'
                    ")
dbDisconnect(con)


braking$cut = cut(braking$v0, breaks = seq(0,150,length.out = 11))

par(mfrow=c(4,3), mar=c(1,1,1,1), oma = c(3,3,0,0))
for (cut in sort(na.omit(unique(braking$cut)))){
  x = braking[braking$cut == cut, c('v0', 'v1', 'dt2', 'cut') ]
  with(x,plot(v0-v1, dt2, ylim=c(0,60), col=rgb(0,0,0,0.1), main=cut, xlim=c(0,150), xaxt='n', yaxt='n'))
  axis(1, lab=T)
  axis(2, lab=T, las=1)
}
mtext(text = 'snelheidsafname (km/h)', side = 1, outer = T)
mtext(text = 'remtijd (s)', side = 2, outer = T)

# clusteren binnen tijd: meerdere kleine remacties binnen 5 minuten?


# plot voor enkele auto (vin == '03662eafcd5b8852e3663484376c027b8b7ea8b30829cae92853ba97d5d63682')
# datum is niet relevant, dus normaliseren naar 1 januri 2017
# makkelijker om dan tijdsvenster aan te passen
a = subset(braking, braking$vin == '03662eafcd5b8852e3663484376c027b8b7ea8b30829cae92853ba97d5d63682')
a$on = strptime(paste('1/1/2017',substr(a$brakeon, 12, 19)), format='%d/%m/%Y %H:%M:%S')
a$off = strptime(paste('1/1/2017',substr(a$brakeoff, 12, 19)), format='%d/%m/%Y %H:%M:%S')
speed$time2 = strptime(paste('1/1/2017',substr(speed$time, 12, 19)), format='%d/%m/%Y %H:%M:%S')


plot(speed$time2, speed$speed, type='o', pch=21, cex=0.4,
  xlim=c(as.numeric(as.POSIXct("2017-01-01 16:23:00")), as.numeric(as.POSIXct("2017-01-01 16:27:00"))), xaxt='n')

rect(xleft = a$on, xright = a$off, ytop = 140, ybottom = 0, col=rgb(0,0,0,0.2), border = NA)

r <- as.POSIXct(round(range(speed$time2), "hours"))
axis.POSIXct(1, at = seq(r[1], r[2], by = "1 min"), format = "%H:%M")
abline(v=seq(r[1], r[2], by = "1 min"), lty=3, col='grey')
text(x = a$on + 0.5*(a$off-a$on), y = 130, labels = round(a$dt1,1), cex=0.6, pos=3)
text(x = a$on + 0.5*(a$off-a$on), y = 125, labels = round(a$dt2,1), cex=0.6, pos=3, col=2)
mtext(text = 'dt2', col=2, cex=0.6, side = 3, line = 0, adj=0)
mtext(text = 'dt1', col=1, cex=0.6, side = 3, line = 0.5, adj=0)
