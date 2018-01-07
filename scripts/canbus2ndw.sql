--CREATE TABLE canbus.tmp_canbusndwspeed as
SELECT 
b.mst_id
,a.geom_rd as geom
,a.time as c_time
,c.l_time as l_time
--,date_trunc('minute',a.time) as c_time
--,count(a.speed) as num_canbus
,a.speed as c_speed
,c.speed as l_speed
,a.speed - c.speed as speeddiff
FROM canbus.data_2017_normalized  a
INNER JOIN ndw.osm_mapping b ON 
	ST_DWithin(a.geom_rd,b.geom_rd,10)
	AND date_part('hour',a.time) > 15
	AND date_part('hour',a.time) <= 19
INNER JOIN LATERAL (
	SELECT 
		avg(array_avg(vehiclespeed)) speed
		,date_trunc('minute',date) l_time
	FROM ndw.trafficspeed 
	WHERE (b.mst_id = location)
	AND date >= a.time - ' 1 minute'::interval
	AND date < a.time + ' 1 minute'::interval
	AND date_trunc('minute',a.time) = date_trunc('minute',date)
	GROUP BY date_trunc('minute',date)
) c ON c.speed Is Not Null
WHERE signalid = 191
AND vin = '807940e893267994237dfc53cf9c1f4a3f9985a41f65e7de9b15f65a7d08aabd'
AND b.mst_id LIKE 'RWS01_MONIBAS%'
/*
GROUP BY 
b.mst_id
,date_trunc('minute',a.time)
*/
ORDER BY c_time
