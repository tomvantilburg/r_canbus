# st_distance vergelijken met snelheid berekend uit snelheid en tijd

require("RPostgreSQL")
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname = "research",
                 host = "localhost", port = 5433,
                 user = "postgres")

## query 1, nog niet zo handig
a <- dbGetQuery(con, "WITH distance AS (
	SELECT 	vin as auto, 
                value as speed, 
                time, 
                ST_Transform(geom, 28992) as geom, 
                DATE_PART('second', time - LAG(time, -1) OVER(ORDER BY vin, time)) dt,
                (value + LAG(value, -1) OVER(ORDER BY vin, time)) / 2 avspeed
                
                FROM canbus.data_2017
                WHERE signalid = 191 AND vin = 'fe41054ca9a55158862afd2b06aafe74eb31900f64ba89e070adaa52555b261b' 
)
--SELECT * from distance
,

distance2 AS (
SELECT min(time) as time, geom, (SUM(d.dt * d.avspeed/3.6)) as x -- km/u naar m/s
FROM 
distance d
GROUP BY geom
ORDER by min(time))

--SELECT * from distance2;

SELECT 	b.time, b.x as calc_dist,
ST_DISTANCE(b.geom, (LAG(b.geom, -1) OVER (ORDER BY b.time))) as geom_dist

FROM distance2 b ORDER BY b.time;
                    ")


dbDisconnect(con)

a$time = as.POSIXct(a$time)#a = subset(x = a, n == 1)

# scatterplot van afstand met ST_DISTANCE en berekende afstand met avgspeed * dt
#png(filename = 'D:/canbus/distance_compared.png', width=15, height=10, units = 'cm', res=180)
plot(a$calc_dist, a$geom_dist, xlim=c(0,100), ylim=c(0,100), 
     xlab='distance from speed and time (m)',
     ylab='distance between GPS positions (m)',
     las=1)
abline(coef=c(1,1))
#dev.off()

# plot verloop van afstand tussen gps-meetpunten gedurende rit
#png(filename = 'D:/canbus/distance_compared_scatter.png', width=15, height=10, units = 'cm', res=180)
plot(as.POSIXct(a$time), a$geom_dist, type='o', col=1, xaxt='n', ylim=c(0,3000), pch=16, cex=0.5,
     xlab = 'time',
     ylab = 'distance between gps positions (m)',
     xlim=c(as.numeric(as.POSIXct("2017-06-01 12:00:00")), as.numeric(as.POSIXct("2017-06-01 13:00:00"))),
     las=1)

# voeg op x-ticks toe per kwartier 
r <- as.POSIXct(round(range(as.POSIXct(a$time)), "hours"))
axis.POSIXct(1, at = seq(r[1], r[2], by = "15 min"), format = "%H:%M")
lines(a$time, a$calc_dist, col=2, pch=16, cex=0.5, type='o')
legend(x='topleft', legend = c('geometric distance (m)', 'calculated from speed and time (m)'), col=c(1,2), lty=1, cex=.6, inset=c(0,-.2), xpd=NA)
#dev.off()