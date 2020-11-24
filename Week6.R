#read file#
read.csv("AF_Final.csv")
AF=read.csv("AF_Final.csv")

colnames(AF)

#data manipulation#
AF$Period <- as.Date(AF$Period, '%m/%d/%Y')

#install packages#
install.packages('ggplot2')
library(ggplot2)

plot(AF$Period, AF$Sales, type = 'l', xlab = 'Period', ylab = 'Sales')

#data visualization#
par(new=TRUE)
plot(AF$Period, AF$Facebook.Impressions, type = 'l', col = 'green', xlab = '', ylab = '', axes = FALSE)

plot(AF$Wechat, AF$Sales, xlab = 'Wechat', ylab = 'Sales')

correl = cor(data[, c(-1,-2)])

write.csv(correl, file = 'Correlation Matrix.csv')

install.packages('corrplot')
library('corrplot')
corrplot(correl, tl.cex = 0.5, tl.col = 'Black')

#Create baseline variables#
AF$Black_Friday = 0
AF[, 'Black_Friday'] = 0 #another way
AF[which(AF$Period == '2014-11-24' ), 'Black_Friday'] =1
AF[which(AF$Period == '2015-11-30' ), 'Black_Friday'] =1
AF[which(AF$Period == '2016-11-28' ), 'Black_Friday'] =1
AF[which(AF$Period == '2017-11-27' ), 'Black_Friday'] =1
sum(AF$Black_Friday) #check 4 spikes

AF$July_4th = 0
AF[, 'July_4th'] = 0 #another way
AF[which(AF$Period == '2014-07-07' ), 'July_4th'] =1
AF[which(AF$Period == '2015-07-06' ), 'July_4th'] =1
AF[which(AF$Period == '2016-07-04' ), 'July_4th'] =1
AF[which(AF$Period == '2017-07-03' ), 'July_4th'] =1
sum(AF$July_4th) #check 4 spikes

#Build Model

#Baselime Model
model1 = lm(data=AF, Sales~CCI+Sales.Event+July_4th+Black_Friday)
summary(model1)

#Add media variables
#Add TV
model2 = lm(data=AF, Sales~CCI+Sales.Event+July_4th+Black_Friday+NationalTV2)
summary(model2)

#Add Search
model3 = lm(data=AF, Sales~CCI+Sales.Event+July_4th+Black_Friday+NationalTV2+PaidSearch1)
summary(model3)

#Add Wechat
model4 = lm(data=AF, Sales~CCI+Sales.Event+July_4th+Black_Friday+NationalTV2+PaidSearch1+Wechat2)
summary(model4)

#Add Magazine
model5 = lm(data=AF, Sales~CCI+Sales.Event+July_4th+Black_Friday+NationalTV2+PaidSearch1+Wechat2+Magazine1)
summary(model5)

#Add Website Display
model6 = lm(data=AF, Sales~CCI+Sales.Event+July_4th+Black_Friday+NationalTV2+PaidSearch1+Wechat2+Magazine1+Display2)
summary(model6)

#Add Facebook
model7 = lm(data=AF, Sales~CCI+Sales.Event+July_4th+Black_Friday+NationalTV2+PaidSearch1+Wechat2+Magazine1+Display2+Facebook1)
summary(model7)

#Export Results
model7 = lm(data=AF, Sales~CCI+Sales.Event+July_4th+Black_Friday+NationalTV2+PaidSearch1+Wechat2+Magazine1+Display2+Facebook1, x=TRUE)
View(model7$x)
model7$coefficients

contribution = sweep(model7$x, 2, model7$coefficients, "*")
View(contribution)
contribution = data.frame(contribution)
contribution$Period = AF$Period
names(contribution) = c(names(model7$coefficients), 'Period')

#Transform contribution into long format
install.packages('reshape')
library('reshape')
contri = melt(contribution, id.vars=('Period'))
View(contri)
write.csv(contri, file = 'contribution.csv', row.names= F)

#Plot AVM
AVM = cbind.data.frame(AF$Period, AF$Sales, model7$fitted.values)
View(AVM)
colnames(AVM) = c('Period', 'Sales', 'Modeled Sales')
write.csv(AVM, file = 'AVM.csv', row.names = F)

#Calculate MAPE
MAPE = abs(AVM$Sales - AVM$`Modeled Sales`)/AVM$Sales
mean(MAPE)

