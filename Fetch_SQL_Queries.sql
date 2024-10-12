-- Go Through the Ipynb file to understand the Transformation done on data . ( Receipts table was exploded using RewardsItemListColumn to get brand information)
-- With the data model taken we can answer more than 2 questions just by using a window function and then taking the
--row number 1. As columns like the total spent , purchase item quantity is going to remain the same. 
-- MYSQL was used for the Queries


-- Q1) When considering average spend from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?

select rewardSreceiptStatus,avg(totalSpent) from
(
	select *, row_number() over (partition by _id order by _id) as rn
	from receipts
) as b
where rewardSreceiptStatus in ("Finished","Rejected") AND rn = 1
group by rewardSreceiptStatus

-- Finished/Accepted has a higher average spent of 80.85 AND Rejected has an average spent of 23.32




-- Q2) When considering total number of items purchased from receipts with 'rewardsReceiptStatus’ of ‘Accepted’
-- or ‘Rejected’, which is greater?

select rewardsReceiptStatus, sum(purchasedItemCount) as total_purchaded_quantity from 
(
	select *, row_number() over (partition by _id order by _id) as rn
	from receipts
) as b
where rn = 1 and rewardsReceiptStatus in ( "FINISHED","REJECTED")
group by rewardsReceiptStatus

--   REJECTED : 173 , FINISHED/ACCEPTED : 8184
--   ACCEPTED/FINISHED IS GREATER




-- Q3) Which brand has the most spend among users who were created within the past 6 months?

select `rewardsReceiptItemList.brandCode`, sum(`rewardsReceiptItemList.finalPrice`*`rewardsReceiptItemList.quantityPurchased`) as brand_revenue
 from receipts
where `rewardsReceiptItemList.brandCode` != "" and userid in ( 
	select _id from users 
	WHERE createdDate >=  ( select DATE_SUB(MAX(DATE_FORMAT(createddate, "%Y-%c-%d")), INTERVAL 6 MONTH) from users ) 
)  
group by `rewardsReceiptItemList.brandCode`
order by sum(`rewardsReceiptItemList.finalPrice`) Desc
limit 1

-- Ben and Jerry's : 4058.499 has the highest spent by the users who have created their account in the last six months.
