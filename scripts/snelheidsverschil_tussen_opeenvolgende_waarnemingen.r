require("RPostgreSQL")
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname = "research",
                 host = "metis", port = 5433,
                 user = "postgres")


speed <- dbGetQuery(con, "
        SELECT value as speed, 
          value - lag(value) OVER (partition by vin order by vin, time) diff, 
          vin as auto, 
          time, 
          location 
        FROM canbus.data_2017
        WHERE signalid = 191 AND time > '2017-04-01'
")

dbDisconnect(con)

plot(density(speed$diff, na.rm=T, bw = 1), xlim=c(-20,20), xlab='change in speed (km/h)', main='', las=1)
abline(v=c(-5,0,5), lty=2)
text(x = c(-5,0,5), y= c(0.145), labels=c('-5', '0', '+5'), pos=3, cex=1, xpd=NA)
legend(x='topleft', col=NA, legend = paste('n = ', nrow(speed)), bty='n', cex=1)
