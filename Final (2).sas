/* Step 1: Import the dataset */
DATA house_price;
    infile "/home/u63571337/Week 8/Bay Area House Price.csv" DLM=',' firstobs=4;
    length address $200 info $100 z_address $100 neighborhood $50 usecode $50;
    input 
        address $ 
        info $ 
        z_address $ 
        bathrooms 
        bedrooms 
        finishedsqft 
        lastsolddate:mmddyy10. 
        lastsoldprice 
        latitude 
        longitude 
        neighborhood $ 
        totalrooms 
        usecode $ 
        yearbuilt 
        zestimate 
        zipcode 
        zpid;
run;

proc print data=house_price(obs=5);
run;
/* Step 2: Drop unnecessary variables using DATA step */

data house_price_cleaned;
    set house_price;
    drop address info z_address neighborhood latitude longitude zpid;
run;

title "Data after dropping variables using DATA step";
proc print data=house_price_cleaned(obs=5);
run;

/* Drop the specified variables using PROC SQL */
proc sql;
    create table house_price as
    select
        bathrooms,
        bedrooms,
        finishedsqft,
        lastsolddate,
        lastsoldprice,
        totalrooms,
        usecode,
        yearbuilt,
        zestimate,
        zipcode
    from house_price_cleaned;
quit;

title "Data after dropping variables using PROC SQL";
proc print data=house_price(obs=5);
run;


/* Step 3: Calculate price_per_square_foot */

/* Add a new variable "price_per_square_foot" using DATA step */
data house_price_cleaned;
    set house_price_cleaned;
    price_per_square_foot = lastsoldprice / finishedsqft;
run;

title "Data after Adding a new variable using DATA step";
proc print data=house_price_cleaned(obs=5);
run;


/* Add a new variable "price_per_square_foot" using PROC SQL */
proc sql;
    create table house_price as
    select *,
           lastsoldprice / finishedsqft as price_per_square_foot
    from house_price_cleaned;
quit;
title "Data after Adding a new variable using PROC SQL";
proc print data=house_price(obs=5);
run;

/* Step 4: Calculate average lastsoldprice by zipcode using Data Statement */

/* Calculate the average of lastsoldprice by zipcode using DATA step */
proc means data=house_price_cleaned;
    class zipcode;
    var lastsoldprice;
    output out=average_prices_zipcode mean=avg_lastsoldprice;
run;

/* Print the values of average lastsoldprice by zipcode using DATA step */
proc print data=average_prices_zipcode(obs=10);
    title "Average Last Sold Price by Zipcode using DATA step";
run;

/* Calculate the average of lastsoldprice by zipcode using PROC SQL */
proc sql;
    create table average_prices_zipcode as
    select zipcode,
           mean(lastsoldprice) as avg_lastsoldprice
    from house_price_cleaned
    group by zipcode;
quit;

/* Print the values of average lastsoldprice by zipcode */
proc print data=average_prices_zipcode(obs=10);
    title "Average Last Sold Price by Zipcode using PROC SQL ";
run;


/* Step 5: Calculate average lastsoldprice by usecode, totalrooms, and bedrooms using Data Statement */
/* Calculate the average of lastsoldprice by usecode, totalrooms, and bedrooms using DATA step */
proc means data=house_price_cleaned noprint;
    class usecode totalrooms bedrooms;
    var lastsoldprice;
    output out=average_prices mean=avg_lastsoldprice;
run;

proc sort data=average_prices;
    by usecode totalrooms bedrooms;
run;

/* Print the values of average lastsoldprice */
proc print data=average_prices(obs=10);
    title "Average Last Sold Price by Use Code, Total Rooms, and Bedrooms using DATA step";
run;


/* Calculate the average of lastsoldprice by usecode, totalrooms, and bedrooms using PROC SQL */
proc sql;
    create table average_prices as
    select usecode,
           totalrooms,
           bedrooms,
           mean(lastsoldprice) as avg_lastsoldprice
    from house_price_cleaned
    group by usecode, totalrooms, bedrooms;
quit;

/* Print the values of average lastsoldprice */
proc print data=average_prices(obs=10);
    title "Average Last Sold Price by Use Code, Total Rooms, and Bedrooms using PROC SQL step";
run;


/* Step 6: Plot bar charts for bathrooms, bedrooms, usecode, totalrooms */
PROC SGPLOT DATA=house_price;
    VBAR bathrooms;
    TITLE "Bar Chart for Bathrooms";
RUN;

PROC SGPLOT DATA=house_price;
    VBAR bedrooms;
    TITLE "Bar Chart for Bedrooms";
    ODS GRAPHICS / IMAGENAME="bedrooms" OUTPUTFMT=png;
RUN;

PROC SGPLOT DATA=house_price;
    VBAR usecode;
    TITLE "Bar Chart for Usecode";
RUN;

PROC SGPLOT DATA=house_price;
    VBAR totalrooms;
    TITLE "Bar Chart for Totalrooms";
RUN;

/* Step 7: Plot Histogram and Boxplot for lastsoldprice and zestimate */
/* Create a histogram for lastsoldprice */
proc univariate data=house_price_cleaned;
    histogram lastsoldprice / normal;
    title "Histogram for Last Sold Price";
run;

/* Create a boxplot for lastsoldprice */
proc sgplot data=house_price_cleaned;
    vbox lastsoldprice;
    title "Boxplot for Last Sold Price";
run;

/* Create a histogram for zestimate */
proc univariate data=house_price_cleaned;
    histogram zestimate / normal;
    title "Histogram for Zestimate";
run;

/* Create a boxplot for zestimate */
proc sgplot data=house_price_cleaned;
    vbox zestimate;
    title "Boxplot for Zestimate";
run;

*Explaination"
"lastsoldprice" has a positive skew (Skewness = 5.301) and positive kurtosis (Kurtosis = 55.274), 
indicating a right-skewed distribution.
"zestimate" also has a positive skew (Skewness = 4.137) and positive kurtosis (Kurtosis = 25.672), i
ndicating a right-skewed distribution.;

/* Calculate the median of lastsoldprice */
proc univariate data=house_price_cleaned noprint;
    var lastsoldprice;
    output out=median_results_LSP median=median_lastsoldprice ;
run;

proc print data=median_results_LSP;
run;
/* Calculate the median of zestimate */
proc univariate data=house_price_cleaned noprint;
    var zestimate;
    output out=median_results_Z median=median_zestimate;
run;

proc print data=median_results_Z;
run;


/* Step 8: Compare the average zestimate for two different zipcodes */

/* Calculate the average zestimate for zip code 94107 */

proc sql;
    title 'T-Test for Average Zestimate by Zip Code';
    select 
        zipcode as ZipCode,
        mean(zestimate) as AverageZestimate
    from house_price_cleaned
    where zipcode in (94107, 94109)
    group by zipcode;
quit;

/* Perform a two-sample t-test */
proc ttest data=house_price_cleaned;
    class zipcode;
    var zestimate;
    where zipcode in (94107, 94109);
run;


*EXPLAINATION: In summary, the statistical analysis indicates a significant difference in the
average Zestimate values between Zip Code 94107 and Zip Code 94109. The lower p-values in the 
t-test results support the conclusion that there is 
indeed a statistically significant distinction between the two zip codes. 
This suggests that the Zestimate values are not the same in these two areas, 
and there are factors contributing to the variance in these real estate estimates.;

/* Step 9: Compare the average zestimate and lastsoldprice */
PROC TTEST DATA=house_price_cleaned;
    VAR zestimate lastsoldprice;
RUN;

*EXPLAINATION: Based on the provided output from the TTEST procedure, it appears that there 
is a statistically significant difference between the average Zestimate and the average of 
Last Sold Price.;


/* Step 10: Explore the association between bedrooms and usecode */
PROC FREQ DATA=house_price_cleaned;
    TABLES bedrooms*usecode / CHISQ;
RUN;

*EXPLAINATION: The statistical analysis shows that there is a significant association between 
the number of bedrooms and the usecode of properties. This means that the number of bedrooms 
is not independent of the usecode. they are related in a statistically significant way. The p-value is extremely small;

/* Step 11: Explore the association between bedrooms and bathrooms */
PROC FREQ DATA=house_price_cleaned;
    TABLES bedrooms*bathrooms / CHISQ;
RUN;

*EXPLAINATION: The statistical analysis shows that there is a significant association between 
the number of bedrooms and the number of bathrooms. They are related in a statistically significant way;

/* Step 12: Calculate correlation coefficients and plot scatter plots and matrix */
/* Calculate the correlation coefficients of all numerical variables with 'zestimate' */
PROC CORR DATA=house_price_cleaned PLOTS(MAXPOINTS=none)=scatter;
   VAR _NUMERIC_;
   WITH zestimate;
   TITLE "Correlation of Numerical Variables with Zestimate";
RUN;


/* Step 13: Build a regression model for zestimate with the first three most correlated variables */
/* Fit a multiple linear regression model */
proc reg data=house_price plots(maxpoints=none);
  model zestimate = bathrooms bedrooms finishedsqft;
  TITLE "question 13) regression model first three most correlated variables.";
run;


/* Step 14: Build a regression model for zestimate with the first five most correlated variables */
proc reg data=house_price plots(maxpoints=none);
  model zestimate = bathrooms bedrooms finishedsqft lastsoldprice totalrooms;
  TITLE "question 14) regression model first five most correlated variables.";
run;


/* Step 15: Compare adjusted R^2 of models from Step 13 and 14 */

*The model from question 14) with the five most correlated variables has a higher adjusted 
R-squared (0.8328), indicating that it explains a larger proportion of the variance in the
zestimate than the model in question 13).

Therefore, the model in question 14) is better in terms of adjusted R-squared.;


/* Step 16: Predict house prices using the better model */


*************************************************;
data new_values;
    input bathrooms bedrooms finishedsqft lastsoldprice totalrooms;
    datalines;
    3 4 2500 1500000 8
    2 3 1800 1200000 6
    4 5 3200 2000000 9
    2.5 3 2000 1300000 7
    ;
run;
data PredictedHousePrices;
	set new_values;
	predicted_zestimate=-106325 + 448.56394 * finishedsqft + 0.77215 * 
		lastsoldprice - 62.61864 * totalrooms - 44038 * bedrooms + 50717 * bathrooms;
run;

proc print data=PredictedHousePrices;
	var predicted_zestimate;
run;


/* Step 17: Export the predictive values to an Excel file */


proc export data=PredictedHousePrices
    outfile='/home/u63571337/Week 8/prediction.xlsx'
    dbms=XLSX
    replace;
    sheet='prediction';
run;



/* Step 18: Create a macro named "average */
%macro average(category, price);
    /* Use PROC MEANS to calculate the mean of &price by &category */
    proc means data=house_price mean noprint;
        class &category;
        var &price;
        output out=averageprice mean=mean_price;
    run;

    /* Use PROC PRINT to print the data averageprice with dynamic titles */
    proc print data=averageprice;
        title "Average &price by &category";
    run;
%mend;


/* Step 19: Calling the macro*/
/* Call the macro to calculate and print the mean of price_per_square_foot by zipcode */
%average(category=zipcode, price=price_per_square_foot);


/* Step 20: Calling the macro*/
/* Call the macro to calculate and print the mean of zestimate by totalrooms */
%average(category=totalrooms, price=zestimate);
