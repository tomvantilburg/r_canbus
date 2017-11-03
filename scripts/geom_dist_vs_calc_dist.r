# st_distance vergelijken met snelheid berekend uit snelheid en tijd

require("RPostgreSQL")
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname = "research",
                 host = "localhost", port = 5433,
                 user = "postgres")

## query 1, nog niet zo handig
m <- dbGetQuery(con, "WITH distance AS (
	SELECT 	vin as auto, 
                value as speed, 
                time, 
                ST_Transform(geom, 28992) as geom, 
                DATE_PART('second', time - Lag(time, 1) OVER(ORDER BY vin, time)) dt,
                (value + Lag(value, 1) OVER(ORDER BY vin, time)) / 2 avspeed
                
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
ST_DISTANCE(b.geom, (Lag(b.geom, 1) OVER (ORDER BY b.time))) as geom_dist

FROM distance2 b ORDER BY b.time;
                    ")


dbDisconnect(con)

plot(m$geom_dist, m$calc_dist,xlim=c(0,1000), ylim=c(0,1000))
lines(x = c(0,10000), y=c(0,10000), lty=2)