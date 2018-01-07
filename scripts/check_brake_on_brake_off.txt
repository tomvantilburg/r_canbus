with w as (
	SELECT vin as auto, 
	  time,
	  value as cur, 
	  LAG(value, -1) OVER (ORDER BY vin, time) as next,
	  ST_Transform(geom, 28992) as geom,
	  date_part('hour', time) as dow
	  FROM canbus.data_2017
	  WHERE signalid = 25 AND time > '2017-04-01'
	),

test_ok as (SELECT w.*, 
CASE WHEN (cur = 1 AND next = 0) THEN 1 else 0 END as ok,
CASE WHEN (cur = 1 AND next = 1) THEN 1 else 0 END as niet_ok
 FROM w)


SELECT SUM(ok), SUM(niet_ok), round(SUM(niet_ok)/ SUM(cur)::numeric ,2) as frac from test_ok
/***
 SUM(cur) geeft aantal records met rem='aan'
 geen grote verschillen tussen maanden, dow, alles tussen 3 en 5 %
***/
