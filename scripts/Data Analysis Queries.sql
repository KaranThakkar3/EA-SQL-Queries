/* Entertainment Agency Database */
/* To find whether the entertainer was booked on Christmas 2017 */
select distinct entertainers.EntertainerID, entertainers.EntStageName, "booked" as booking_status
from entertainers
left join engagements on engagements.EntertainerID = entertainers.EntertainerID
where engagements.StartDate <= '2017-12-25' and engagements.EndDate >= '2017-12-25'
union
select distinct entertainers.EntertainerID, entertainers.EntStageName, "not booked"
from entertainers
left join engagements on engagements.EntertainerID = entertainers.EntertainerID
where entertainers.EntertainerID not in 
(select entertainers.EntertainerID from entertainers
left join engagements on engagements.EntertainerID = entertainers.EntertainerID
where engagements.StartDate <= '2017-12-25' and engagements.EndDate >= '2017-12-25');		


/* Check for customers who like Jazz but not Standards */
select customers.CustFirstName, customers.CustLastName from customers
left join musical_preferences on musical_preferences.CustomerID = customers.CustomerID
left join musical_styles on musical_preferences.StyleID = musical_styles.StyleID
where musical_styles.StyleName = "Jazz" and musical_preferences.CustomerID not in 
(select musical_preferences.CustomerID from musical_preferences
left join musical_styles on musical_styles.StyleID = musical_preferences.StyleID
where musical_styles.StyleName = "Standards");


/*  Running total of the number of styles selected for all the customers */
select customers.CustomerID, concat(customers.CustFirstName,' ',customers.CustLastName) as name, musical_styles.StyleName,
count(customers.CustomerID) over (partition by customers.CustomerID) as total_preferences,
count(customers.CustomerID) over (order by concat(customers.CustFirstName,' ',customers.CustLastName)) as running_total
from customers
left join musical_preferences on musical_preferences.CustomerID = customers.CustomerID
left join musical_styles on musical_styles.StyleID = musical_preferences.StyleID
order by customers.CustFirstName, running_total; 


/* Number the entertainers overall and number the engagements within each start date */
select engagements.EngagementNumber, engagements.StartDate, customers.CustFirstName, entertainers.EntStageName,
dense_rank() over (order by entertainers.EntStageName) as num_entertainer,
row_number() over (partition by engagements.StartDate) as num_engagement
from engagements
left join customers on customers.CustomerID = engagements.CustomerID
left join entertainers on entertainers.EntertainerID = engagements.EntertainerID;


/* Rank entertainers based on no of engagements and arrange into 3 buckets */
select entertainers.EntStageName,
count(distinct engagements.EngagementNumber) as num_engagements,
ntile(3) over (order by count(distinct engagements.EngagementNumber) desc) as Bucket,
dense_rank() over (order by count(distinct engagements.EngagementNumber) desc) as ent_rank
from entertainers
left join engagements on engagements.EntertainerID = entertainers.EntertainerID
group by entertainers.EntStageName;




