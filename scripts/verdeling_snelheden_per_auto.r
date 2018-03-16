# snelheidsverdeling per auto
# genereert plot met snelheidsverdeling van alle auto's erin

require("RPostgreSQL")
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname = "research",
                 host = "metis", port = 5433,
                 user = "postgres")


df <- dbGetQuery(con, "
        SELECT value as speed, vin as auto from canbus.data_2017
          WHERE signalid = 191 AND time > '2017-04-01'")

dbDisconnect(con)

# frequentietabel per auto-id
n = table(df$auto)

# omzetten naar dataframe
n = data.frame(n)

# filter auto-id's met > 1000 waarnemingen
n = n[n$Freq > 1000,]

# neem waarnemingen van die auto's met snelheid > 5 (veeel 0)
df2 = df[df$auto %in% n$Var1 & df$speed > 5,]

# bepaal per auto de kernel density
a = tapply(X = df2$speed, INDEX = df2$auto, FUN = function(r) {c(density(r, from = 0, to = 200, n = 100)$y)}, simplify=T)

cols = rgb(red = c(0,1), green = 0, blue = 0, alpha = 0.1)
output <- matrix(unlist(a), ncol = 100, byrow = TRUE)
matplot(x=seq(0,200,length.out = 100), y = t(output), 
        col=rgb(red = 0, green = 0, blue = 0, alpha = 0.02), lty=1, type='l',
        xlab='snelheid (km/u)',
        ylab='density', las=1)
