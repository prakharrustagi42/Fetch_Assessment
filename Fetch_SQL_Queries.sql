-- 3 QUESTIONS ARE ANSWERED

-- Q1) When considering average spend from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?


select rewardSreceiptStatus,avg(totalSpent) from receipts
where rewardSreceiptStatus in ("Finished","Rejected")
group by rewardSreceiptStatus

-- Finished/Accepted has a higher average spent of 80.85 AND Rejected has an average spent of 23.32



-- Q2) When considering total number of items purchased from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’
-- , which is greater?

select rewardsReceiptStatus, sum(purchasedItemCount) as total_purchaded_quantity 
from receipts
where  rewardsReceiptStatus in ( "FINISHED","REJECTED")
group by rewardsReceiptStatus

--   REJECTED : 173 , FINISHED/ACCEPTED : 8184    :  ACCEPTED/FINISHED IS GREATER



-- Q3) Which brand has the most spend among users who were created within the past 6 months?

select brandcode, sum(amount_spend_on_item) as spent_on_brand  from (
	select rl.*, (rl.finalprice * rl.quantitypurchased) as amount_spend_on_item, r.userid, u._id
	from rewarditemlist rl
    left join receipts r on ( rl.oid = r._id)
	left join users u on ( r.userid = u._id)
	where rl.brandCode != "" and r.userid in ( 
		select _id from users 
		WHERE createdDate >=  ( select DATE_SUB(MAX(DATE_FORMAT(createddate, "%Y-%c-%d")), INTERVAL 6 MONTH) from users ) 
	)
) as b 
group by brandcode
order by sum(amount_spend_on_item) desc 
limit 1


------------------------ OR USING CTEs as a faster way ----------------------------------------------


With CTE_1 AS (
select r.*
from receipts r left join users u on (
	r.userid = u._id
) 
where r.userid in ( 
	select _id from users 
	WHERE createdDate >=  ( select DATE_SUB(MAX(DATE_FORMAT(createddate, "%Y-%c-%d")), INTERVAL 6 MONTH) from users ))
) 

, CTE_2 AS (

select *, (finalprice * quantitypurchased) as amount_spend_on_item
from rewarditemlist
) 

select c2.brandcode,sum(amount_spend_on_item) as amount_spend_on_brand from CTE_1 c1 left join CTE_2 c2 on (
	c1._id = c2.oid
    )
where c2.brandcode != ""
group by c2.brandcode
order by sum(amount_spend_on_item) DESC
limit 1


-- both give answer as CRACKER BARREL -- 6162.66
