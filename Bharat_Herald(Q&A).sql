show tables;

select * from ad_category;
select * from ad_revenue;
select * from city;
select * from city_readiness;
select * from digital_pilot;
select * from print_sales;

desc ad_category;
desc ad_revenue;
desc city;
desc city_readiness;
desc digital_pilot;
desc print_sales;

-- Questions from the available data (Primary)

-- 1. Print Circulation Trends
-- What is the trend in copies printed, copies sold, and net circulation across all
-- cities from 2019 to 2024? How has this changed year-over-year?

SELECT
    YEAR(month) AS year,
    SUM(copies_sold + copies_returned) AS copies_printed,
    SUM(copies_sold) AS copies_sold,
    SUM(net_circulation) AS net_circulation
FROM print_sales
WHERE month BETWEEN '2019-01-01' AND '2024-12-31'
GROUP BY YEAR(month)
ORDER BY year;

-- 2. To Performing Cities
-- Which cities contributed the highest to net circulation and copies sold in 2024?

select c.city,
sum(p.copies_sold) as total_copies_sold,
sum(p.net_circulation) as total_net_circulation
from print_sales p
join city c
on c.city_id = p.city_id
where p.month between '2024-01-01' and '2024-12-31'
group by city
order by total_net_Circulation desc, total_copies_sold DESC;

-- 3. Print Waste Analysis
-- Which cities have the largest gap between copies printed and net circulation, and
-- how has that gap changed over time?

select  YEAR(p.month) AS year,
c.city,
sum(p.copies_sold + p.copies_returned) as copies_printed,
sum(p.net_circulation) as net_circulation,
sum(p.copies_sold + p.copies_returned) - sum(p.net_circulation) as gap
from print_sales p
join city c
on c.city_id = p.city_id
group by year(p.month), c.city
order by c.city, year;

-- 4. Ad Revenue Trends by Category
-- How has ad revenue evolved across different ad categories between 2019 and
-- 2024? Which categories have remained strong, and which have declined?

ALTER TABLE ad_revenue
ADD COLUMN year CHAR(10);

UPDATE ad_revenue
SET year =
CASE
    WHEN quarter LIKE '____-Q%' THEN LEFT(quarter, 4)
    WHEN quarter LIKE 'Q%-____' THEN RIGHT(quarter, 4)
    WHEN quarter LIKE '%Qtr %' THEN RIGHT(quarter, 4)
END;

SELECT
    r.year,
    c.category_group,
    ROUND(
        SUM(
            CASE
                WHEN r.currency = 'USD' THEN r.ad_revenue * 86
                WHEN r.currency = 'EUR' THEN r.ad_revenue * 101
                ELSE r.ad_revenue
            END
        ), 2
    ) AS total_revenue_in_inr
FROM ad_revenue r
JOIN ad_category c
ON r.ad_category = c.ad_category_id
GROUP BY r.year, c.category_group
ORDER BY r.year, total_revenue_in_inr DESC;


-- 5. City-Level Ad Revenue Performance
-- Which cities generated the most ad revenue, and how does that correlate with
-- their print circulation?

SELECT
    c.city,
    ROUND(
        SUM(
            CASE
                WHEN r.currency = 'USD' THEN r.ad_revenue * 86
                WHEN r.currency = 'EUR' THEN r.ad_revenue * 101
                ELSE r.ad_revenue
            END
        ), 2
    ) AS total_revenue_in_inr,
    SUM(p.net_circulation) AS net_circulation
FROM ad_revenue r
JOIN print_sales p
ON r.edition_id = p.edition_id
JOIN city c
ON c.city_id = p.city_id
GROUP BY c.city
ORDER BY total_revenue_in_inr DESC;

-- 6. Digital Readiness vs. Performance
-- Which cities show high digital readiness (based on smartphone, internet, and
-- literacy rates) but had low digital pilot engagement?

WITH city_analysis AS
(
    SELECT
        c.city,
        ROUND(AVG(r.literacy_rate),2) AS literacy_rate,
        ROUND(AVG(r.smartphone_penetration),2) AS smartphone_penetration,
        ROUND(AVG(r.internet_penetration),2) AS internet_penetration,

        ROUND(
            (AVG(r.literacy_rate) +
             AVG(r.smartphone_penetration) +
             AVG(r.internet_penetration)) / 3,
             2
        ) AS digital_readiness_score

    FROM city c
    JOIN city_readiness r
    ON c.city_id = r.city_id

    GROUP BY c.city
)

SELECT *
FROM city_analysis
ORDER BY digital_readiness_score DESC;WITH city_analysis AS
(
    SELECT
        c.city,
        ROUND(AVG(r.literacy_rate),2) AS literacy_rate,
        ROUND(AVG(r.smartphone_penetration),2) AS smartphone_penetration,
        ROUND(AVG(r.internet_penetration),2) AS internet_penetration,

        ROUND(
            (AVG(r.literacy_rate) +
             AVG(r.smartphone_penetration) +
             AVG(r.internet_penetration)) / 3,
             2
        ) AS digital_readiness_score

    FROM city c
    JOIN city_readiness r
    ON c.city_id = r.city_id

    GROUP BY c.city
)

SELECT *
FROM city_analysis
ORDER BY digital_readiness_score DESC;

-- 7. Ad Revenue vs. Circulation ROI
-- Which cities had the highest ad revenue per net circulated copy? Is this ratio
-- improving or worsening over time?

select c.city,
sum(p.net_circulation) as circulation,
round(sum(r.ad_revenue), 2) as total_revenue,
ROUND(
        SUM(r.ad_revenue) / SUM(p.net_circulation),
        2
    ) AS ad_revenue_per_copy
from city c
join print_sales p 
on c.city_id = p.city_id
join ad_revenue r
on r.edition_id = p.edition_id
group by city 
order by ad_revenue_per_copy desc;

-- 8. Digital Relaunch City Prioritization
--  Based on digital readiness, pilot engagement, and print decline, which 3 cities should be
-- prioritized for Phase 1 of the digital relaunch?

UPDATE digital_pilot
SET city_id = REPLACE(city_id, CHAR(13), '');

SELECT
    c.city,

    ROUND(
        (AVG(r.literacy_rate) +
         AVG(r.smartphone_penetration) +
         AVG(r.internet_penetration)) / 3,
        2
    ) AS digital_readiness,

    ROUND(AVG(dp.downloads_or_accesses),2) AS pilot_engagement,

    ROUND(
        (
            AVG(ps.copies_sold + ps.copies_returned)
            - AVG(ps.net_circulation)
        )
        /
        AVG(ps.copies_sold + ps.copies_returned) * 100,
        2
    ) AS print_decline_percent

FROM city c
JOIN city_readiness r
    ON c.city_id = r.city_id
JOIN digital_pilot dp
    ON c.city_id = dp.city_id
JOIN print_sales ps
    ON c.city_id = ps.city_id

GROUP BY c.city

ORDER BY
    digital_readiness DESC,
    pilot_engagement DESC,
    print_decline_percent DESC

LIMIT 3;













