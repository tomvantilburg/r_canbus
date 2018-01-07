/* 
  Creates one big table where all signaldata is normalized into their own columns.
  Handle with care since it doesn't notice missing data. Original signalid is added as column.
*/
DROP TABLE canbus.data_2017_normalized;
CREATE TABLE canbus.data_2017_normalized AS
WITH normalized AS (
	SELECT 
	vin,
	time,
	geom,
	signalid,
	CASE WHEN signalid = 13 THEN VALUE END AS temp,
	CASE WHEN signalid = 25 THEN value END AS brake,
	CASE WHEN signalid = 100 THEN VALUE END AS fogfront,
	CASE WHEN signalid = 102 THEN VALUE END AS fuel,
	CASE WHEN signalid = 112 THEN VALUE END AS hazard,
	CASE WHEN signalid = 170 THEN VALUE END AS fogrear,
	CASE WHEN signalid = 191 THEN value END AS speed,
	CASE WHEN signalid = 253 THEN VALUE END AS wipefast,
	CASE WHEN signalid = 254 THEN VALUE END AS wipeint,
	CASE WHEN signalid = 257 THEN VALUE END AS wipemot,
	CASE WHEN signalid = 258 THEN VALUE END AS wipeonce,
	CASE WHEN signalid = 262 THEN VALUE END AS wipeslow
	FROM canbus.data_2017  
	--WHERE vin = '00056f66da29e6b615aafa0ee2ea418a669eafefae1c93ee3aafe6bf56d1c502'
	ORDER BY time
)

SELECT vin, time, geom, signalid
  ,first_value(temp) OVER (PARTITION BY vin, temp_partition ORDER BY time) As temp
	,first_value(brake) OVER (PARTITION BY vin, brake_partition ORDER BY time) As brake
	,first_value(fogfront) OVER (PARTITION BY vin, fogfront_partition ORDER BY time) As fogfront
	,first_value(fuel) OVER (PARTITION BY vin, fuel_partition ORDER BY time) As fuel
	,first_value(hazard) OVER (PARTITION BY vin, hazard_partition ORDER BY time) As hazard
	,first_value(fogrear) OVER (PARTITION BY vin, fogrear_partition ORDER BY time) As fogrear
	,first_value(speed) OVER (PARTITION BY vin, speed_partition ORDER BY time) As speed
	,first_value(wipefast) OVER (PARTITION BY vin, wipefast_partition ORDER BY time) As wipefast
	,first_value(wipeint) OVER (PARTITION BY vin, wipeint_partition ORDER BY time) As wipeint
	,first_value(wipemot) OVER (PARTITION BY vin, wipemot_partition ORDER BY time) As wipemot
	,first_value(wipeonce) OVER (PARTITION BY vin, wipeonce_partition ORDER BY time) As wipeonce
	,first_value(wipeslow) OVER (PARTITION BY vin, wipeslow_partition ORDER BY time) As wipeslow
	
FROM (
  select *
  ,sum(case when temp is null then 0 else 1 end) over (partition by vin order by time ) as temp_partition
  ,sum(case when brake is null then 0 else 1 end) over (partition by vin order by time ) as brake_partition
  ,sum(case when fogfront is null then 0 else 1 end) over (partition by vin order by time ) as fogfront_partition
  ,sum(case when fuel is null then 0 else 1 end) over (partition by vin order by time ) as fuel_partition
  ,sum(case when hazard is null then 0 else 1 end) over (partition by vin order by time ) as hazard_partition
  ,sum(case when fogrear is null then 0 else 1 end) over (partition by vin order by time ) as fogrear_partition
  ,sum(case when speed is null then 0 else 1 end) over (partition by vin order by time ) as speed_partition
  ,sum(case when wipefast is null then 0 else 1 end) over (partition by vin order by time ) as wipefast_partition
  ,sum(case when wipeint is null then 0 else 1 end) over (partition by vin order by time ) as wipeint_partition
  ,sum(case when wipemot is null then 0 else 1 end) over (partition by vin order by time ) as wipemot_partition
  ,sum(case when wipeonce is null then 0 else 1 end) over (partition by vin order by time ) as wipeonce_partition
  ,sum(case when wipeslow is null then 0 else 1 end) over (partition by vin order by time ) as wipeslow_partition
  FROM normalized
) As q;