WITH distance AS (
  SELECT vin, 
	value as speed, 
	time, 
	ST_Transform(geom, 28992) as geom, 
	EXTRACT(EPOCH FROM (time - LAG(time, 1) OVER(ORDER BY vin, time))) dt,
	(value + LAG(value, 1) OVER(ORDER BY vin, time)) / 2 avspeed
  FROM canbus.data_2017
  WHERE signalid = 191 
	AND vin = '71481e11a9d0804b1121dbd7b1d102ad84ff45e39427ada094c31a1adbaa4969' 
),

--SELECT * from distance
-- som van afgelegde afstanden (v*dt) per gps-punt
distance2 AS (
  SELECT 
	time, 

	speed, 
	dt,
	avspeed, 
	(d.dt * d.avspeed/3.6)*1 as calc_dist, -- km/u naar m/s
	geom
  FROM distance d
  ORDER by time
)
--SELECT * from distance2;

SELECT 
	b.*, 
	ST_DISTANCE(b.geom, (LAG(b.geom, 1) OVER (ORDER BY b.time))) as geom_dist
FROM distance2 b 
ORDER BY b.time