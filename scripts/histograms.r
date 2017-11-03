require("RPostgreSQL")
require("ggplot2")
require("quantreg")
rain <- read.csv(file='/home/tomt/data/neerslaggeg_APELDOORN_543.csv',header=TRUE, sep=',')
rain$Date <- as.Date(as.character(rain$YYYYMMDD),format='%Y%m%d')
rain <- subset(rain, rain$Date> "2017-02-01" & rain$Date < "2017-10-12")
Sys.setlocale(category = "LC_TIME", locale = "C")
rain$Month <-  format(rain$Date,'%b')
rain$Month <- factor(rain$Month,unique(all$Month))
rain$Day <-  format(rain$Date,'%d')
rain$day <- as.numeric(rain$Day)
rain$Year <- format(rain$Date,'%Y')
rain$year <- as.numeric(all$Year)
ggplot(rain,aes(Date,RD)) + geom_point(shape=".") + geom_smooth() + theme_bw()


drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname = "research",
                 host = "localhost", port = 5433,
                 user = "postgres")
df_postgres <- dbGetQuery(con, "
        SELECT signalid, avg(value) as value, date_trunc('day',time) as time from canbus.data_2017 
        WHERE signalid = 13
        GROUP BY signalid, date_trunc('day',time)
")
#ggplot(df_postgres, aes(value)) + geom_freqpoly(binwidth = 2) + theme_bw()
ggplot(df_postgres,aes(time,value)) + geom_point(shape="o") + geom_smooth() + theme_bw()

df_postgres <- dbGetQuery(con, "
        SELECT signalid, count(value) as value, date_part('week',time) as time from canbus.data_2017 
        WHERE signalid IN (253,254,257,262)
        GROUP BY signalid, date_part('week',time)
")
#ggplot(df_postgres, aes(value)) + geom_freqpoly(binwidth = 2) + theme_bw()
ggplot(df_postgres,aes(time,value)) + geom_point(shape="o") + geom_smooth() + theme_bw()

#Histogram of time interval between speed measurements
df_postgres <- dbGetQuery(con, "
WITH diff AS (
  SELECT vin,
  geom,
  date_part('seconds',time - lag(time) OVER (PARTITION BY vin ORDER BY time)) AS diff
  FROM canbus.data_2017  
  WHERE time > '2017-03-19'
  AND signalid = 191
)
SELECT vin, max(diff) diff FROM diff 
WHERE diff Is Not Null
GROUP BY vin, geom;
")
ggplot(df_postgres,aes(diff)) + geom_histogram() +theme_bw()
