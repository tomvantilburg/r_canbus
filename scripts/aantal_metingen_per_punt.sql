SELECT min(time) as time, COUNT(*), min(value) min_v, max(value) as max_v, EXTRACT(EPOCH FROM (max(time)-MIN(time))) as dt, geom FROM canbus.data_2017
WHERE signalid = 191 AND time > '2017-09-01' --AND vin = '03662eafcd5b8852e3663484376c027b8b7ea8b30829cae92853ba97d5d63682'
GROUP BY geom, vin
ORDER BY vin, time;