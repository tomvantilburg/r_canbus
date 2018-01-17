  WITH x AS (SELECT vin, 
    min(time) as min_time, 
    max(time) as max_time, 
    COUNT(*) as count, 
    min(value) min_v, 
    max(value) as max_v, 
    --EXTRACT(EPOCH FROM (max(time)-MIN(time))) as dt, 
    EXTRACT(EPOCH FROM (min(time) - LAG(max(time), 1) OVER(PARTITION BY vin ORDER BY min(time)))) dt,
    --EXTRACT(EPOCH FROM (max(time) - (min(time)))) dt,
    --st_x(geom_rd), st_y(geom_rd),
    geom 
    FROM canbus.data_2017
    WHERE signalid = 191 AND time > '2017-04-01' AND vin = '71481e11a9d0804b1121dbd7b1d102ad84ff45e39427ada094c31a1adbaa4969' 
    GROUP BY vin, geom
    ORDER BY vin, min_time)

SELECT * FROM x;
    SELECT count, count(*) as f FROM x WHERE count > dt GROUP by count ORDER by count;

SELECT * FROM canbus.data_2017 
WHERE vin = '53ff1783176687df9ffadccc23bc88064d0ce4888bac0f0b9144c14cd2db71bc' AND signalid = 191
ORDER BY time