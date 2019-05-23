#Read data
geo_fence <- read.csv("~/Desktop/UCI/Coursework/BANA 277 LEC A- CUST & SOCIAL ANLYTICS/Assignments/Geo-Fence Analytics.csv")

#Creating Dummy variables
geo_fence$imp_large <- ifelse(geo_fence$imp_size == '728x90', '1', '0')
geo_fence$cat_entertainment <- ifelse(geo_fence$app_topcat == 'IAB1' | geo_fence$app_topcat == 'IAB1 - 6','1', '0')
geo_fence$cat_social <- ifelse(geo_fence$app_topcat == 'IAB14', '1', '0')
geo_fence$cat_tech <- ifelse(geo_fence$app_topcat == 'IAB19-6', '1', '0')
geo_fence$os_ios <-ifelse(geo_fence$device_os == 'iOS', '1', '0')

library(aspace)
#Harvesine formula
geo_fence$distance <- 6371*acos(cos(as_radians(geo_fence$device_lat)) * cos(as_radians(geo_fence$geofence_lat)) * cos(as_radians(geo_fence$device_lon) - as_radians(geo_fence$geofence_lon)) + sin(as_radians(geo_fence$device_lat)) * sin(as_radians(geo_fence$geofence_lat)))
geo_fence$distance_squared <- geo_fence$distance * geo_fence$distance                   
geo_fence$ln_app_review_vol <- log(geo_fence$app_review_vol)

colnames(geo_fence)

#Copying the important variables in a new dataframe for further analysis
new_df <- geo_fence[,c(15,21,22,16,17,18,19,20,23,7)]


#Grouping distance into buckets and calculating clickthrough rate
new_df$group_distance = new_df$distance
new_df$group_distance[new_df$distance>=0 & new_df$distance<=0.5] = 1
new_df$group_distance[new_df$distance>0.5 & new_df$distance<=1] = 2
new_df$group_distance[new_df$distance>1 & new_df$distance<=2] = 3
new_df$group_distance[new_df$distance>2 & new_df$distance<=4] = 4
new_df$group_distance[new_df$distance>4 & new_df$distance<=7] = 5
new_df$group_distance[new_df$distance>7 & new_df$distance<=10] = 6
new_df$group_distance[new_df$distance>10] = 7

library(stats)
new_df$clickthrough_rate <- ave(new_df$didclick, new_df$group_distance)

#Summarize the new dataframe
str(new_df)
summary(new_df)

#Converting the catagorical variables to numeric
new_df$imp_large <- as.numeric(new_df$imp_large)
new_df$cat_entertainment <- as.numeric(new_df$cat_entertainment)
new_df$cat_social <- as.numeric(new_df$cat_social)
new_df$cat_tech <- as.numeric(new_df$cat_tech)
new_df$os_ios <- as.numeric(new_df$os_ios)



#Correlation using library corrgram
library(corrgram)
cor(new_df)
cols <- colorRampPalette(c("darkgoldenrod4", "burlywood1", "darkkhaki", "darkblue"))
corrgram(new_df, order = TRUE, col.regions = cols, 
         lower.panel = panel.shade,
         upper.panel = panel.conf,
         text.panel = panel.txt,
         main = 'A corrgram')

#Correlation using library Corrplot
library(corrplot)
correlations <- cor(new_df)
corrplot(correlations, method = 'circle', type = 'lower')

#plot relationship between distance group and clickthrough rate
g <- ggplot(new_df, aes(x=group_distance, y=clickthrough_rate)) + 
      geom_line() + geom_point() + 
      xlab('Distance group') + 
      ylab('Clickthrough Rate') +
      ggtitle('Relationship between Distance group and clickthrough rate')
plot(g)

new_df$impressions <- c(1)
plot(new_df %>% 
       group_by(app_review_val) %>% 
       summarise(ctr = sum(didclick)/sum(impressions)), xlab('App star ratings'), ylab('Clickthrough Rate'), title('Relationship between App star ratings and clickthrough rate'))
plot(new_df %>% 
       group_by(ln_app_review_vol) %>% 
       summarise(ctr = sum(didclick)/sum(impressions)), xlab('Number of reviews'), ylab('Clickthrough Rate'), title('Relationship between Number of reviews and clickthrough rate'))

#Logistic regression
reg <- glm(didclick ~ distance + distance_squared + imp_large + cat_entertainment + 
             cat_social + cat_tech + os_ios + ln_app_review_vol + app_review_val,
           data = new_df, family = binomial())
summary(reg)

#Checking for colleanearity with VIF
library(car)
vif(reg)

#The VIF value is greater than 10 for distance and distance_squared indicating high correlation between them
#This is obvious as distance squared term has been evaluated from distance.
#Only keeping distance squared term for our final model

reg1 <- glm(didclick ~ distance_squared + imp_large + cat_entertainment + 
             cat_social + cat_tech + os_ios + ln_app_review_vol + app_review_val,
           data = new_df, family = binomial())
summary(reg1)
plot(reg1)

#Model estimation using Anova and chi-squared test
anova(reg1, test = 'Chisq')
#Difference between null deviance and the residual deviance shows how our model is doing against the null model
#The wider this gap the better. 4 variables have high deviance and have a significant p value

#Calculating the exponential of coefficents because log(odds) are difficult to interpret
exp(coef(reg1))

#Testing out another model with just the 3 significant variables observed from last model
reg2 <- glm(didclick ~ imp_large + cat_tech + os_ios, data = new_df, family = binomial())
summary(reg2)
plot(reg2)

#Likelihood ratio test to compare both models
library(lmtest)
lrtest(reg1, reg2)

#Anova means to compare both models
anova(reg1, reg2)





