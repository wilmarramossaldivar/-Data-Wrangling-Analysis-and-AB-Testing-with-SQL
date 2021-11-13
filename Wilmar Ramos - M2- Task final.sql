-- Wilmar Ramos
------------------------------------------------------------------------------------------------------------------
-- 1 Compare the final_assignments_qa table to the assignment events we captured for user_level_testing. Write an answer to the following question: Does this table have everything you need to compute metrics like 30-day view-binary?

SELECT 
  * 
FROM 
  dsv1069.final_assignments_qa
  
--ANSWER: No, we need the date and time of assignment to compute metrics like 30-day view-binary!
  
------------------------------------------------------------------------------------------------------------------
-- 2 Write a query and table creation statement to make final_assignments_qa look like the final_assignments table. If you discovered something missing in part 1, you may fill in the value with a place holder of the appropriate data type. 

--Reformat the final_assignments_qa to look like the final_assignments table, filling in any missing values with a placeholder of the appropriate data type.

SELECT item_id,
       test_a AS test_assignment,
       'test_a' AS test_number,
       CAST('2020-01-01 00:00:00' AS timestamp) AS dummy_test_start_date
FROM dsv1069.final_assignments_qa
UNION ALL
SELECT item_id,
       test_b AS test_assignment,
       'test_b' AS test_number,
       CAST('2020-01-01 00:00:00' AS timestamp) AS dummy_test_start_date
FROM dsv1069.final_assignments_qa
UNION ALL
SELECT item_id,
       test_c AS test_assignment,
       'test_c' AS test_number,
       CAST('2020-01-01 00:00:00' AS timestamp) AS dummy_test_start_date
FROM dsv1069.final_assignments_qa
UNION ALL
SELECT item_id,
       test_d AS test_assignment,
       'test_d' AS test_number,
       CAST('2020-01-01 00:00:00' AS timestamp) AS dummy_test_start_date
FROM dsv1069.final_assignments_qa
UNION ALL
SELECT item_id,
       test_e AS test_assignment,
       'test_e' AS test_number,
       CAST('2020-01-01 00:00:00' AS timestamp) AS dummy_test_start_date
FROM dsv1069.final_assignments_qa
UNION ALL
SELECT item_id,
       test_f AS test_assignment,
       'test_f' AS test_number,
       CAST('2020-01-01 00:00:00' AS timestamp) AS dummy_test_start_date
FROM dsv1069.final_assignments_qa

------------------------------------------------------------------------------------------------------------------
-- 3 Use the final_assignments table to calculate the order binary for the 30 day window after the test assignment for item_test_2 (You may include the day the test started)
-- Use this table to
-- compute order_binary for the 30 day window after the test_start_date
-- for the test named item_test_2

SELECT order_binary.test_assignment,
       COUNT(DISTINCT order_binary.item_id) AS num_orders,
       SUM(order_binary.orders_bin_30d) AS sum_orders_bin_30d
FROM
  (SELECT assignments.item_id,
          assignments.test_assignment,
          MAX(CASE
                  WHEN (DATE(orders.created_at)-DATE(assignments.test_start_date)) BETWEEN 1 AND 30 THEN 1
                  ELSE 0
              END) AS orders_bin_30d
   FROM dsv1069.final_assignments AS assignments
   LEFT JOIN dsv1069.orders AS orders
     ON assignments.item_id=orders.item_id
   WHERE assignments.test_number='item_test_2'
   GROUP BY assignments.item_id,
            assignments.test_assignment) AS order_binary
GROUP BY order_binary.test_assignment

------------------------------------------------------------------------------------------------------------------
-- 4 Use the final_assignments table to calculate the view binary, and average views for the 30 day window after the test assignment for item_test_2. (You may include the day the test started)
-- Use this table to
-- compute view_binary for the 30 day window after the test_start_date
-- for the test named item_test_2

SELECT view_binary.test_assignment,
       COUNT(DISTINCT view_binary.item_id) AS num_views,
       SUM(view_binary.view_bin_30d) AS sum_view_bin_30d,
       AVG(view_binary.view_bin_30d) AS avg_view_bin_30d
FROM
  (SELECT assignments.item_id,
          assignments.test_assignment,
          MAX(CASE
                  WHEN (DATE(views.event_time)-DATE(assignments.test_start_date)) BETWEEN 1 AND 30 THEN 1
                  ELSE 0
              END) AS view_bin_30d
   FROM dsv1069.final_assignments AS assignments
   LEFT JOIN dsv1069.view_item_events AS views
     ON assignments.item_id=views.item_id
   WHERE assignments.test_number='item_test_2'
   GROUP BY assignments.item_id,
            assignments.test_assignment
   ORDER BY item_id) AS view_binary
GROUP BY view_binary.test_assignment
------------------------------------------------------------------------------------------------------------------
-- 5 Use the https://thumbtack.github.io/abba/demo/abba.html to compute the lifts in metrics and the p-values for the binary metrics ( 30 day order binary and 30 day view binary) using a interval 95% confidence. 

--For orders_bin: lift is -15% – 11% (-2.2%) and pval is 0.74
--For views_bin: lift is and pval is -2.1% – 5.9% (1.9%) and pval is 0.36
--Therefore for item_test_2, there was no significant difference in either the number of views or the number of orders between control and experiment

------------------------------------------------------------------------------------------------------------------
-- 6 Use Mode’s Report builder feature to write up the test. Your write-up should include a title, a graph for each of the two binary metrics you’ve calculated. The lift and p-value (from the AB test calculator) for each of the two metrics, and a complete sentence to interpret the significance of each of the results.

--PARAMETER 
-- Label	|| Number of successes	|| Number of trials
-- Baseline || 1 || 3
-- Variation 1 || 12  || 12
-- Interval confidence level: 0.95
-- Result: 

	      Successes	Total	Success Rate	p-value	Improvement
Baseline	1	3	
5.6% – 80% (33%)

Variation 1	12	12	
72% – 100% (100%) 0.011	
11% – 200% (200%)

