###
# api for getting online plots (run with plumbeR)
# author: TomT
###

#* @get /normalDistribution
normalDistribution <- function(n = 10) {
  rnorm(n)
}

#* @png
#* @get /fundamenteelDiagram
fundamenteelDiagram <- function(id) {
  require("RPostgreSQL")
  require("ggplot2")
  
  drv <- dbDriver("PostgreSQL")
  con <- dbConnect(drv, dbname = "research",
                   host = "localhost", port = 5433,
                   user = "postgres")
  qry <- sprintf("
  WITH elements AS (
                      SELECT mst_id,json_array_elements(characteristics) elem
                 FROM ndw.mst_points
                 WHERE mst_id = '%s'
            )
                 ,indices AS (
                 SELECT 
                 mst_id,
                 (elem->>'index')::int as index,
                 elem->'measurementSpecificCharacteristics'->>'specificMeasurementValueType' as type
                 FROM elements
                 WHERE 
                 elem->'measurementSpecificCharacteristics'->'specificVehicleCharacteristics'->>'vehicleType' = 'anyVehicle'
                 ),
                 data AS (
                 SELECT DISTINCT a.date, a.location, 
                 b.index as index, 
                 b.type as type, 
                 CASE WHEN b.type ='trafficSpeed' THEN values[b.index] END as speedvalue,
                 CASE WHEN b.type ='trafficFlow' THEN values[b.index] END as flowvalue
                 FROM 
                 ndw.trafficspeed_2 a
                 INNER JOIN indices b ON (a.location = b.mst_id)
                 WHERE --a.date = '2017-10-27T12:13:00Z' 
                 a.date > now() - '7 days'::interval
                 AND a.values[b.index] > 0
                 )
                 SELECT 
                 date, location, date_part('hour',date) as tod,
                 avg(speedvalue) as speed_avg, count(speedvalue) as speedvalues,
                 sum(flowvalue) as flow_sum, count(flowvalue) as flowvalues
                 FROM data a
                 GROUP BY a.location, a.date
                 ",id)
  df_postgres <- dbGetQuery(con,qry)
  
  print(ggplot(df_postgres,aes(flow_sum,speed_avg, colour = factor(tod))) + geom_point(shape="o") + theme_bw())
}
