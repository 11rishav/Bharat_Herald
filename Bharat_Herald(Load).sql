create database Bharat_Herald;
use Bharat_Herald;

create table ad_revenue
       (
       edition_id varchar(200),
       ad_category varchar(200),
       quarter varchar(200),
       ad_revenue float,
       currency varchar(100),
       comments varchar(200));
       
       Load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/fact_ad_revenue.csv'
       into table ad_revenue
       fields terminated by ','
       enclosed by '"'
       lines terminated by '\n'
       ignore 1 rows
       (edition_id,	ad_category,	quarter,	ad_revenue,	currency,	comments);
       
       create table digital_pilot
              (
              platform varchar(200),
              launch_month date,
              ad_category_id varchar(100),
              dev_cost int,
              marketing_cost int,
              users_reached int,
              downloads_or_accesses int,
              avg_bounce_rate float,
              cumulative_feedback_from_customers varchar(200),
              city_id char(10));
            
		load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/fact_digital_pilot.csv'
        into table digital_pilot
        fields terminated by ','
        enclosed by '"'
        lines terminated by '\n'
        ignore 1 rows
        (@dummy, platform,	@launch_month,	ad_category_id,	dev_cost,	marketing_cost,	
        users_reached,	downloads_or_accesses,	avg_bounce_rate,	cumulative_feedback_from_customers,	city_id)
        SET launch_month = STR_TO_DATE(CONCAT(@launch_month,'-01'), '%Y-%m-%d');
        
        create table city_readiness
            (
            city_id	varchar(100),
            quarter	varchar(100),
            literacy_rate float,
            smartphone_penetration float,
            internet_penetration float);
            
            LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/fact_city_readiness.csv'
INTO TABLE city_readiness
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    @dummy,
    city_id,
    quarter,
    literacy_rate,
    smartphone_penetration,
    internet_penetration
);
            
	create table ad_category
                (
                ad_category_id varchar(200),
                standard_ad_category varchar(200),
                category_group varchar(200),
                example_brands varchar(200));
            
	Load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dim_ad_category.csv'
    into table ad_category
    Fields terminated by ','
    enclosed by '"'
    lines terminated by '\n'
    ignore 1 rows
    (ad_category_id,	standard_ad_category,	category_group,	example_brands);
            
	
	create table city
        (
        city_id varchar(100),
        city varchar(100),
        state varchar(100),
        tier varchar(100))
   
   Load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dim_city.csv'
   into table city
   fields terminated by ','
   enclosed by '"'
   lines terminated by '\n'
   ignore 1 rows
   (city_id,	city,	state,	tier);
   
   create table print_sales
          (
          edition_ID varchar(200),
          City_ID varchar(200),
          Language varchar(200),
          State varchar(200),
          Month date,
          Copies_Sold int,
          copies_returned int,
          Net_Circulation int);
          
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/fact_print_sales.csv'
INTO TABLE print_sales
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    edition_ID,
    City_ID,
    Language,
    State,
    @month,
    Copies_Sold,
    copies_returned,
    Net_Circulation
)
SET month =
CASE
    WHEN @month LIKE '%/%'
        THEN STR_TO_DATE(CONCAT(@month,'/01'), '%Y/%m/%d')
    ELSE
        STR_TO_DATE(CONCAT('01-',@month), '%d-%b-%y')
END;
       
       
       