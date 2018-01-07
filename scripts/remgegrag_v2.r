# positie toevoegen
# naar dataframe

require("RPostgreSQL")

drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname = "research",
                 host = "metis", port = 5433,
                 user = "postgres")

fn = "C:/Users/joepk/Documents/GitHub/r_canbus/scripts/query_braking.sql"
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


braking$cols = cut(braking$v0, breaks = seq(0,150,length.out = 11))
colramp = heat.colors(n=10, alpha=1)
with(braking2,plot(v1-v0, dt, ylim=c(0,60), col=colramp[cols], xlim=c(-150,0)))

# datum is niet relevant, dus normaliseren naar 1 januri 2017
# makkelijker om dan tijdsvenster aan te passen
braking$on = strptime(paste('1/1/2017',substr(braking$brakeon, 12, 19)), format='%d/%m/%Y %H:%M:%S')
braking$off = strptime(paste('1/1/2017',substr(braking$brakeoff, 12, 19)), format='%d/%m/%Y %H:%M:%S')
speed$time2 = strptime(paste('1/1/2017',substr(speed$time, 12, 19)), format='%d/%m/%Y %H:%M:%S')

par(mfrow=c(4,3), mar=c(1,1,1,1), oma = c(2,2,0,0))
for (cut in sort(na.omit(unique(braking$cols)))){
  x = braking[braking$cols == cut, c('v0', 'v1', 'dt2', 'cols') ]
  with(x,plot(v0-v1, dt2, ylim=c(0,60), col=rgb(0,0,0,0.1), main=cut, xlim=c(0,150), xaxt='n', yaxt='n'))
  axis(1, lab=F)
  axis(2, lab=F)
}
mtext(text = 'snelheidsafname (km/h)', side = 1, outer = T)
mtext(text = 'remtijd (s)', side = 2, outer = T)

# clusteren binnen tijd: meerdere kleine remacties binnen 5 minuten?


# plot voor enkele auto
# plot(speed$time2, speed$speed, type='o', pch=21, cex=0.4,
#   xlim=c(as.numeric(as.POSIXct("2017-01-01 16:00:00")), as.numeric(as.POSIXct("2017-01-01 16:30:00"))), xaxt='n')
# a = subset(braking, braking$vin == '03662eafcd5b8852e3663484376c027b8b7ea8b30829cae92853ba97d5d63682')
# rect(xleft = braking$on, xright = braking$off, ytop = 140, ybottom = 0, col=rgb(0,0,0,0.2), border = NA)
# 
# r <- as.POSIXct(round(range(speed$time2), "hours"))
# axis.POSIXct(1, at = seq(r[1], r[2], by = "15 min"), format = "%H:%M")