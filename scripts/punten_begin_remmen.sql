
-- remsignalen en geometrie naar RD
WITH b AS (
  SELECT vin as auto, 
  time,
  value, 
  ST_Transform(geom, 28992) as geom
  FROM canbus.data_2017
  WHERE signalid = 25 AND vin = '71481e11a9d0804b1121dbd7b1d102ad84ff45e39427ada094c31a1adbaa4969' 
),

-- snelheidsmetingen en geometrie
v AS (
  SELECT vin as auto, 
  value as speed, 
  time,
  ST_Transform(geom, 28992) as geom
  FROM canbus.data_2017
  WHERE signalid = 191 AND vin = '71481e11a9d0804b1121dbd7b1d102ad84ff45e39427ada094c31a1adbaa4969' 
),

bk AS(
	SELECT 
		b.*, 
		CASE WHEN b.value - LAG(b.value, -1) OVER(PARTITION BY auto ORDER BY time) = 1 THEN LAG(b.time, -1) OVER(PARTITION BY auto ORDER BY time)
			ELSE NULL
			END as time2,
		CASE WHEN b.value - LAG(b.value, -1) OVER(PARTITION BY auto ORDER BY time) = 1 THEN 'brakeon'
			ELSE 'brakeoff'
			END as aanuit
	FROM b
) ,

b3 AS (
	SELECT bk.time as aan, bk.time2 as uit, bk.aanuit as signal, geom, null::integer as "value" --, 'brake'::text as "signal"
	FROM bk
	UNION 
	SELECT time as aan, null::timestamp as uit, 'speed'::text as "signal", geom, speed as value 
	FROM v
	ORDER by aan
),

b4 AS (
	SELECT aan, uit, geom, value, signal, 
	CASE WHEN signal = 'brakeon' AND uit > aan THEN LAG(value, -1) OVER(ORDER BY aan)
		WHEN signal = 'brakeoff' AND uit is NULL THEN LAG(value, 1) OVER(ORDER BY aan)
		ELSE NULL
	END as v0,
	EXTRACT(EPOCH FROM uit - aan) as dt
	FROM b3
	), -- SELECT * FROM b4

brakeoff AS(
SELECT time, geom from b where value = 0
),

-- selecteer rem-uit momenten
c as (SELECT aan, v0 as v1 FROM b4 WHERE signal = 'brakeoff' ),

-- voeg snelheid en tijdstip van rem-uit toe aan rem-aan o.b.v. timestamp
final as (SELECT b4.aan as brakeon, b4.uit as brakeoff, b4.v0, c.v1, b4.dt, b4.geom FROM b4
JOIN c ON b4.uit = c.aan),


joined as (
SELECT bk.time as time, bk.geom as geom, brakeoff.geom as geom2 from bk JOIN brakeoff
ON bk.time2 = brakeoff.time
where bk.aanuit = 'brakeon')

SELECT j.time, j.geom as geom, final.v0, final.v1, final.dt from joined j JOIN final
ON j.time = final.brakeon;
