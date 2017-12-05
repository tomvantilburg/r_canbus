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

# datum is niet relevant, dus normaliseren naar 1 januri 2017
# makkelijker om dan tijdsvenster aan te passen
braking$on = strptime(paste('1/1/2017',substr(braking$brakeon, 12, 19)), format='%d/%m/%Y %H:%M:%S')
braking$off = strptime(paste('1/1/2017',substr(braking$brakeoff, 12, 19)), format='%d/%m/%Y %H:%M:%S')
speed$time2 = strptime(paste('1/1/2017',substr(speed$time, 12, 19)), format='%d/%m/%Y %H:%M:%S')

plot(speed$time2, speed$speed, type='o', pch=21, cex=0.4,
  xlim=c(as.numeric(as.POSIXct("2017-01-01 16:00:00")), as.numeric(as.POSIXct("2017-01-01 16:30:00"))), xaxt='n')
a = subset(braking, braking$vin == '03662eafcd5b8852e3663484376c027b8b7ea8b30829cae92853ba97d5d63682')
rect(xleft = braking$on, xright = braking$off, ytop = 140, ybottom = 0, col=rgb(0,0,0,0.2), border = NA)

r <- as.POSIXct(round(range(speed$time2), "hours"))
axis.POSIXct(1, at = seq(r[1], r[2], by = "15 min"), format = "%H:%M")