SELECT * FROM hotel_performance_dashboard.hotel_management_1000_rows;

USE hotel_performance_dashboard;

ALTER TABLE hotel_performance_dashboard.hotel_management_1000_rows
RENAME hotel_performance;

SELECT * FROM hotel_performance;

-- Q1. Total bookings
SELECT COUNT(*) AS Total_Booking FROM hotel_performance; 

-- Q2. Total revenue
SELECT SUM(Total_Amount) AS Total_Revenue FROM hotel_performance; 

-- Q3. Average room rate
SELECT AVG(Room_Rate) AS AverageRoom_Rate FROM hotel_performance; 

-- Q4. Bookings by room type
SELECT Room_Type, COUNT(Booking_ID) AS Bookings 
FROM hotel_performance GROUP BY Room_Type ORDER BY Bookings DESC;

-- Q5. Revenue by room type
SELECT Room_Type, SUM(Total_Amount) AS Revenue 
FROM hotel_performance GROUP BY Room_Type ORDER BY Revenue DESC;

-- Q6. Find total completed bookings.
SELECT Booking_Status, COUNT(Booking_ID) AS Completed_Bookings 
FROM hotel_performance WHERE Booking_Status = "Completed" ORDER BY Completed_Bookings DESC;

-- Q7. Find total cancelled bookings.
SELECT Booking_Status, COUNT(Booking_ID) AS Cancelled_Bookings 
FROM hotel_performance WHERE Booking_Status = "Cancelled" ORDER BY Cancelled_Bookings DESC;

-- Q8. Calculate cancellation rate.
WITH cancellation AS (
    SELECT COUNT(Booking_ID) AS Cancelled_Bookings 
    FROM hotel_performance 
    WHERE Booking_Status = 'Cancelled'
), 
totalbooking AS ( 
    SELECT COUNT(*) AS Total_Booking 
    FROM hotel_performance
) 
SELECT 
    (can.Cancelled_Bookings / total.Total_Booking) * 100 AS Cancellation_Rate
FROM cancellation AS can
CROSS JOIN totalbooking AS total;

-- Q9. Find revenue by city.
SELECT City, SUM(Total_Amount) AS Revenue 
FROM hotel_performance GROUP BY City ORDER BY Revenue DESC; 
-- Q10. Find bookings by booking channel.
SELECT Booking_Channel, COUNT(Booking_ID) AS Booking 
FROM hotel_performance 
GROUP BY Booking_Channel 
ORDER BY Booking DESC; 

-- Q11. Find average stay by room type.
SELECT Room_Type, AVG(Nights) AS Averge_Stay 
FROM hotel_performance 
GROUP BY Room_Type 
ORDER BY Averge_Stay DESC; 

-- Q12. Find top 5 customers by revenue.
SELECT Customer_ID, Customer_Name, SUM(Total_Amount) AS Revenue 
FROM hotel_performance GROUP BY Customer_ID, Customer_Name ORDER BY Revenue DESC LIMIT 5; 

-- Q13. Find top 5 cities by revenue.
SELECT City, SUM(Total_Amount) AS Revenue 
FROM hotel_performance GROUP BY City ORDER BY Revenue DESC LIMIT 5; 

-- Q14. Find monthly revenue.
SELECT DATE_FORMAT(Check_In, '%Y %M') AS Years_Month, SUM(Total_Amount) AS Revenue 
FROM hotel_performance 
GROUP BY DATE_FORMAT(Check_In, '%Y-%m'), DATE_FORMAT(Check_In, '%Y %M')
ORDER BY DATE_FORMAT(Check_In, '%Y-%m') ASC;

-- Q15. Find monthly booking.
SELECT DATE_FORMAT(Check_In, '%Y %M') AS Years_Month, COUNT(Booking_ID) AS Booking 
FROM hotel_performance 
GROUP BY DATE_FORMAT(Check_In, '%Y-%m'), DATE_FORMAT(Check_In, '%Y %M')
ORDER BY DATE_FORMAT(Check_In, '%Y-%m') ASC;

-- Q16. Find revenue by payment method.
SELECT Payment_Method, SUM(Total_Amount) AS Revenue 
FROM hotel_performance GROUP BY Payment_Method ORDER BY Revenue DESC; 

-- Q17. Find the most popular room type.
SELECT Room_Type, COUNT(Booking_ID) AS Bookings 
FROM hotel_performance GROUP BY Room_Type ORDER BY Bookings DESC LIMIT 1;

-- Q18. Find the most popular booking channel.
SELECT Booking_Channel, COUNT(Booking_ID) AS Bookings 
FROM hotel_performance GROUP BY Booking_Channel ORDER BY Bookings DESC;

-- Q19. Rank room types by revenue using RANK().
SELECT Room_Type, SUM(Total_Amount) AS Revenue,
RANK()OVER(ORDER BY Room_Type) AS Ranks
FROM hotel_performance GROUP BY Room_Type ORDER BY Revenue DESC;

-- Q20. Calculate monthly revenue using GROUP BY.
SELECT DATE_FORMAT(Check_In, '%Y-%M') AS Years_Month, SUM(Total_Amount) AS Revenue
FROM hotel_performance 
GROUP BY DATE_FORMAT(Check_In, '%Y-%m'), DATE_FORMAT(Check_In, '%Y-%M') 
ORDER BY DATE_FORMAT(Check_In, '%Y-%m') ASC;

-- Q21. Calculate running monthly revenue using a window function.
SELECT DATE_FORMAT(Check_In, '%Y %M') AS Years_Month, 
SUM(SUM(Total_Amount))OVER(ORDER BY DATE_FORMAT(Check_In, '%Y-%m')) AS Revenue 
FROM hotel_performance 
GROUP BY DATE_FORMAT(Check_In, '%Y-%m'), DATE_FORMAT(Check_In, '%Y %M')
ORDER BY DATE_FORMAT(Check_In, '%Y-%m') ASC;

-- Q22. Find customers whose revenue is above average.
SELECT Customer_ID, Customer_Name, SUM(Total_Amount) AS Total_Customer_Revenue 
FROM hotel_performance
GROUP BY Customer_ID, Customer_Name
HAVING SUM(Total_Amount) > (SELECT AVG(Customer_Total) FROM (SELECT SUM(Total_Amount) AS Customer_Total 
			FROM hotel_performance GROUP BY Customer_ID) AS Subquery);

-- Q23. Find the highest-revenue customer in each city.
WITH RankedRevenue AS (
    SELECT Customer_ID, Customer_Name, City, SUM(Total_Amount) AS Total_Revenue,
	DENSE_RANK() OVER (PARTITION BY City ORDER BY SUM(Total_Amount) DESC) AS Revenue_Rank
    FROM hotel_performance GROUP BY Customer_ID, Customer_Name, City
)
SELECT Customer_ID, Customer_Name, City, Total_Revenue 
FROM RankedRevenue WHERE Revenue_Rank = 1;

-- Q24. Find cancellation rate by booking channel.
SELECT 
    Booking_Channel,
    ROUND(AVG(Booking_Status = 'Cancelled') * 100, 2) AS Cancellation_Rate_Percentage
FROM hotel_performance
GROUP BY Booking_Channel;

-- Q25. Find the month with maximum revenue.
SELECT 
    DATE_FORMAT(Check_In, '%Y %M') AS Highest_Revenue_Month, 
    SUM(Total_Amount) AS Max_Revenue
FROM hotel_performance
GROUP BY 
    DATE_FORMAT(Check_In, '%Y-%m'), 
    DATE_FORMAT(Check_In, '%Y %M')
ORDER BY Max_Revenue DESC
LIMIT 1;
