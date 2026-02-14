--  View 1: Historical Churn Dataset
-- Includes customers who have either Churned or Stayed.
-- This dataset is used for churn model training and performance evaluation.

CREATE VIEW vw_Churndata as
    select * from prod_churn where Customer_Status IN ('Churned','Stayed')

-- View 2: New Customer Dataset
-- Includes customers who have recently Joined.
-- This dataset is used for churn prediction scoring after the model has been trained.
Create View vw_JoinData as
    select * from prod_churn where Customer_Status = 'Joined'