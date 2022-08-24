library(ipumsr)
library(ipumsr)
library(sf)
library(dplyr)
library(knitr)
library(fastDummies)

ddi <- read_ipums_ddi("Data/usa_00016.xml")
data <- read_ipums_micro(ddi)

#Remove intervals of weeks worked
data$WKSWORK1<-0
data$WKSWORK1[data$WKSWORK2==1]=6.5
data$WKSWORK1[data$WKSWORK2==2]=20
data$WKSWORK1[data$WKSWORK2==3]=33.5
data$WKSWORK1[data$WKSWORK2==4]=43.5
data$WKSWORK1[data$WKSWORK2==5]=48
data$WKSWORK1[data$WKSWORK2==6]=52



data<-as.data.frame(subset(data,WKSWORK1>=35 & UHRSWORK>=30 & INCWAGE!=999999 & INCWAGE!=999998 & INCWAGE>=0))
data<-subset(data,STATEFIP<=57)


#Generate years of education
data$yearsed[data$EDUC==0]=0
data$yearsed[data$EDUC==01]=4
data$yearsed[data$EDUC==02]=6
data$yearsed[data$EDUC==03]=8
data$yearsed[data$EDUC==04]=9
data$yearsed[data$EDUC==05]=10
data$yearsed[data$EDUC==06]=11
data$yearsed[data$EDUC==07]=12
data$yearsed[data$EDUC==08]=13
data$yearsed[data$EDUC==09]=14
data$yearsed[data$EDUC==10]=15
data$yearsed[data$EDUC==11]=16

#Generate College dummy
data$collegeyesno[data$EDUC>=10]<-1
data$collegeyesno[data$EDUC<10]<-0

#Generate 'potential' experience
data$potentialexp<-data$AGE-data$yearsed-6
data$hourlywages<-data$INCWAGE/(data$WKSWORK1*data$UHRSWORK)

#Convert Gender to dummy
data$male[data$SEX==1]=1
data$male[data$SEX!=1]=0

#convert year to dummy
data$year_2018<-0
data$year_2018[data$YEAR==2018]<-1

#Convert race to dummies
data$race_white<-0
data$race_white[data$RACE==1]<-1


#Drop 0 wage individuals
data<-data[data$hourlywages>0,]


#Drop Redundant Variables
data$WKSWORK2<- NULL
data$UHRSWORK<-NULL
data$INCWAGE<-NULL
data$EDUC<-NULL
data$EDUCD<-NULL
data$SEX<-NULL


#Label the states
#data$STATE<-factor(state$C("AL","AR","AK","CA","CR","CO","CT","DE","DC","FL","GE","HA","ID","IL","IN","IO","KA","KN","LA","ME","MD","MA","MC","MI","MS","MR","MO","NB","NE","NH","NJ","NM","NY","NC","ND","OH","OK","OR","PA","RI","SC","SD","TN","TX","UT","VE","VI","WA","WV","WI","WY"))

#Add in the nhgis data

library(ipumsr)
library(sf)
library(dplyr)


#Load in GIS
nhgis_csv<-"nhgis0005_csv.zip"
nhgis_shp<-"nhgis0005_shape.zip"
nhgis_ddi<-read_ipums_codebook(nhgis_csv)
nhgis<-read_nhgis_sf(data_file = nhgis_csv,shape_file = nhgis_shp)

#Create empty colums for returns to tenure/education
nhgis$educreturn<-0
nhgis$tenurereturn<-0
