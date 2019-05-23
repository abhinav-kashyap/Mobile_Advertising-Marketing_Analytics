# Mobile-Advertising---Marketing-Analytics
This project deals with location based mobile marketing. The data is from a location-based marketing agency which handles geo-fencing campaigns on behalf of advertisers <br> <br>
Due to the very large volume of data, I only looked at a random sample for two campaigns of a single advertiser –
AMC Theaters. The advertising impressions are inserted into the mobile app being used on the device. The data include the following elements: impression size (e.g., 320x50 pixels), app category (e.g., IAB1), app review volume and valence, device OS (e.g., iOS), geo-fence lat/long coordinates, mobile device lat/long coordinates, and click outcome (0 or 1). <br> <br>
The analysis is done to plot the relationship of distance and click through rate along with other similar pairs giving useful insights. I also worked on Binomial Logistic regression to calculate the probabilty of 'didclick' (people who click on an advertisement) given certain factors. <br> <br>

<b> Results </b>

I was able to conclude that the number of clicks depends on the following factors: <br>
1)	The size of the impression. The larger the impression size is the less chances the user will click on it. With 1 unit increase in impression size, the clickthrough rate decreases by a factor of 0.7 <br>
2)	Device type. iOS users click on an ad more often than Android users. Thus, if a user uses an iOS device, the chances of clicking on app increases by a factor of 1.47 <br>
3)	App category “IAB19-6” is highly significant in predicting higher clickthrough rate. This category was earlier classified as cat_tech. <br> <br>

I also looked at the relationship of other variables in the model with clickthrough rate, although because these variables are not significant in the model, their importance is low. <br>
1.	People are less likely to click on the app if they are farther away from desired location. <br>
2.	Higher App reviews contribute to higher number of clicks.
