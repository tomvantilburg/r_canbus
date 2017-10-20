## nog doen: zoek snelheid voor en na remmen bij het rem-event

require("RPostgreSQL")
library("RColorBrewer")
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname = "research",
                 host = "localhost", port = 5433,
                 user = "postgres")

# snelheid van gegeven auto
speed <- dbGetQuery(con, "
        SELECT value as speed, vin as auto, time, location from canbus.data_2017
          WHERE signalid = 191 AND vin = 'fe41054ca9a55158862afd2b06aafe74eb31900f64ba89e070adaa52555b261b'
")

# remgedrag van gegeven auto
brake <- dbGetQuery(con, "
        SELECT value as brake, vin as auto, time, location from canbus.data_2017
          WHERE signalid = 25 AND vin = 'fe41054ca9a55158862afd2b06aafe74eb31900f64ba89e070adaa52555b261b'
")

s = speed

# rem aan
b = brake[brake$brake==1,]

# rem uit
l = brake[brake$brake==0,]

plot(s$time, s$speed, type='o', pch=3, cex=0.5, 
     xlim=c(as.numeric(as.POSIXct("2017-06-01 12:00:00")), as.numeric(as.POSIXct("2017-06-01 12:20:00"))))
rug(x=b$time, col=2, lwd=2, ticksize =0.03)
rug(x=l$time, col=3, lwd=2, ticksize =0.03)

# zoek eerst waarneming 'brake = 0' volgend op 'brake = 1'
eerstvlgnd = apply(X = b, MARGIN = 1, FUN = function(x) {as.vector(
                    c(x[as.numeric(as.POSIXct(x[3])),
                      l$time[min(which(as.POSIXct(l$time) > as.POSIXct(x[3])))]))})
eerstvlgnd = data.frame(t(eerstvlgnd))
colnames(eerstvlgnd) = c('rem_aan', 'rem_uit')

# als een waarneming brake = 0 aan meerdere brake =1 gekoppeld is, toekennen aan laatste
x = eerstvlgnd[!rev(duplicated(rev(eerstvlgnd$rem_uit))),]

rect(xleft = x[,1], xright = x[,2], ytop = 100, ybottom = 0, col=rgb(0,0,0,0.2), border='black')



# sp = spline(s$time, s$speed,n=10*nrow(s))
# sp$y[sp$y<0] <- 0
# lines(sp, col = 2)

