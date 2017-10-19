require("RPostgreSQL")
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname = "research",
                 host = "localhost", port = 5433,
                 user = "postgres")


df <- dbGetQuery(con, "
        SELECT value as speed, vin as auto from canbus.data_2017
          WHERE signalid = 191
")

# frequentietabel per auto-id
n = table(df$auto)

# omzetten naar dataframe
n = data.frame(n)

# filter auto-id's met > 1000 waarnemingen
n = n[n$Freq > 1000,]

# neem waarnemingen van die auto's met snelheid > 5 (veeel 0)
df2 = df[df$auto %in% n$Var1 & df$speed > 5,]

# bepaal per auto de kernel density
a = tapply(X = df2$speed, INDEX = df2$auto, FUN = density)

# leeg plotje maken
plot(NULL, xlim=c(0,200), ylim = c(0,0.02), las=1,
     xlab='snelheid (km/u)', 
     ylab='density')

# voor iedere auto de lijn van density tekenen
for (auto in a){
  lines(auto, col=rgb(0,0,0,alpha = 0.02))
}
