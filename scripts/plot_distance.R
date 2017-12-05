a = read.table('C:\\Users\\joepk\\Desktop\\dist3.csv', sep=';', header=T)

a$time = as.POSIXct(a$time)#a = subset(x = a, n == 1)

png(filename = 'D:/canbus/distance_compared.png', width=15, height=10, units = 'cm', res=180)
plot(a$calc_dist, a$geom_dist, xlim=c(0,100), ylim=c(0,100), 
     xlab='distance from speed and time (m)',
     ylab='distance between GPS positions (m)',
     las=1)
abline(coef=c(1,1))
dev.off()

png(filename = 'D:/canbus/distance_compared_scatter.png', width=15, height=10, units = 'cm', res=180)
plot(as.POSIXct(a$time), a$geom_dist, type='o', col=1, xaxt='n', ylim=c(0,3000), pch=16, cex=0.5,
     xlab = 'time',
     ylab = 'distance between gps positions (m)',
     xlim=c(as.numeric(as.POSIXct("2017-06-01 12:00:00")), as.numeric(as.POSIXct("2017-06-01 13:00:00"))),
     las=1)

r <- as.POSIXct(round(range(as.POSIXct(a$time)), "hours"))
axis.POSIXct(1, at = seq(r[1], r[2], by = "15 min"), format = "%H:%M")
lines(a$time, a$calc_dist, col=2, pch=16, cex=0.5, type='o')
legend(x='topleft', legend = c('geometric distance (m)', 'calculated from speed and time (m)'), col=c(1,2), lty=1, cex=.6, inset=c(0,-.2), xpd=NA)
dev.off()