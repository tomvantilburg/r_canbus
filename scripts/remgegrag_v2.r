# positie toevoegen
# naar dataframe

require("RPostgreSQL")
library("RColorBrewer")
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname = "research",
                 host = "localhost", port = 5433,
                 user = "postgres")


speed <- dbGetQuery(con, "
                    SELECT value as speed, vin as auto, time, location from canbus.data_2017
                    WHERE signalid = 191 AND time >= '2017-09-01'
                    ")

brake <- dbGetQuery(con, "
                    SELECT value as brake, vin as auto, time, location from canbus.data_2017
                    WHERE signalid = 25 AND time >= '2017-09-01'
                    ")

dbDisconnect(con)

# lijst van unieke auto-id's
autos = unique(speed$auto)
print(length(autos))


# plot(NULL, xlim=c(0,150), ylim=c(-15,2), xlab = 'snelheid begin (km/h)', ylab = 'versnelling (km/h/s)', las=1)
plot(NULL, xlim=c(-100,0), ylim=c(0,30), xlab = 'snelheidsverschil (km/h)', ylab = 'tijdsverschil (s)', las=1)
for (auto in autos){
  
  # kies een willekeurige auto
  #i = 88
  #auto = autos[i]
  
  #print(which(autos==auto))
  
  # snelheid
  s = speed[speed$auto == auto,]
  
  # rem aan
  b = brake[brake$brake==1 & brake$auto == auto,]
  
  # rem uit
  l = brake[brake$brake==0 & brake$auto == auto,]
  
  # zoek eerst waarneming 'brake = 0' volgend op 'brake = 1'
  eerstvlgnd = apply(X = b, MARGIN = 1, FUN = function(x) {as.vector(
    c(as.numeric(as.POSIXct(x[3])),
      l$time[min(which(as.POSIXct(l$time) > as.POSIXct(x[3])))]))})
  
  eerstvlgnd = data.frame(t(eerstvlgnd))
  colnames(eerstvlgnd) = c('rem_aan', 'rem_uit')
  
  # als een waarneming brake = 0 aan meerdere brake = 1 gekoppeld is, toekennen aan laatste
  #abline(v=eerstvlgnd[duplicated(eerstvlgnd$X2),2])
  rem = eerstvlgnd[!rev(duplicated(rev(eerstvlgnd$rem_uit))),]
  
  v = apply(X = rem, MARGIN = 1, FUN = function(x) {as.vector(
    c(as.numeric(x[1]),
      as.numeric(x[2]),
      s$time[min(which(as.numeric(s$time) > x[1]))],
      s$speed[min(which(as.numeric(s$time) > x[1]))], 
      s$time[max(which(as.numeric(s$time) < x[2]))],
      s$speed[max(which(as.numeric(s$time) < x[2]))]))})
  
  v = data.frame(t(v))
  colnames(v)  = c('rem_aan', 'rem_uit', 't0', 'v0', 't1', 'v1')
  v$dt = (v$t1 - v$t0)
  v$dv = (v$v1 - v$v0)
  v$a = v$dv / v$dt
  
  # rem-momenten met netto-toename in snelheid weglaten
  v[v$dv >= 0 & !is.na(v$a), c('a', 'dt')] <- NA
  v[v$dt <= 0 & !is.na(v$dt), c('a','dt')] <- NA
  
  
  #points(v$v0, v$a, col=rgb(0,0,0,0.05), pch=16, cex=0.5)
  points(v$dv, v$dt, col=rgb(0,0,0,0.1), pch=16, cex=0.5)
}


# test remmomenten voor een auto
# plot(s$time, s$speed, type='o', pch=16, cex=0.5)
# rug(x=b$time, col=2, lwd=2, ticksize =0.03)
# rug(x=l$time, col=3, lwd=2, ticksize =0.03)

# col = rev(brewer.pal(n = 9, name = 'Reds'))
# rect(xleft = v$t0, xright = v$t1, ytop = v$v0, ybottom = v$v1, col=rgb(red=t(col2rgb(col[cut(v$a, b = 8)])), alpha = 100, maxColorValue = 255))
