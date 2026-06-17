# Exercise 5: Validate the Migrated Azure SQL Database

The migration to Azure SQL Database is now complete, but a successful migration is about more than moving data. Before Zava can rely on the new platform for reporting, analytics, and decision-making, the migrated environment must be validated to ensure data accuracy and functionality.

Jessie, a Business Intelligence Analyst, is preparing for an upcoming leadership review and needs confidence that the migrated sales data is complete, accurate, and ready for business use. Together, Mark and Jessie validate the migrated database, confirm that all database objects were transferred successfully, and verify that the data can support future reporting and analytics workloads.

In this exercise, you will connect to the migrated Azure SQL Database, verify migrated database objects, and validate that the data and database functionality have been successfully preserved during the migration process.

## ✅ Outcome

- Successfully connected to the migrated Azure SQL Database
- Data consistency validated between source and target environments
- Views, stored procedures, functions, and triggers are tested successfully
- Migrated database confirmed ready for reporting and analytics

### Task 5.1: Connect to the Migrated Azure SQL Database​
1. Click on the **Target database** link (**sqldb-rgworkiqlab-f1-06151713336**) in the Migrations table to view the migrated Azure SQL Database.

	![Step 1.png](../../media/image49.png)

2. In the left navigation menu, click on **Query editor (preview)**, select **SQL authentication**, enter **sqladmin** for the username, enter the SQL admin password, and then click **Connect**.

	![Step 2.png](../../media/image50.png)





### Task 5.2: Verify Migrated Database Objects​

3. In the **Query editor Explorer**, expand the **dbo** schema and verify that the **Tables** folder contains all 15 migrated tables: **__migration_status**, **carriers**, **customers** etc.

	![Step 3.png](../../media/image51.png)

4. Continue scrolling in the Explorer to verify the remaining database objects: **Views** , **Stored Procedures**, **Scalar Functions** , and **Table-Valued Functions**.

	![Step 4.png](../../media/image52.png)


### Task 5.3: Validate Data and Database Functionality



5. In the Explorer, right-click on the **customers** table and select **Select top 1000 rows** from the context menu.

	![Step 5.png](../../media/image53.png)

6. The query `SELECT TOP (1000) * FROM [dbo].[customers]` will be auto-populated in the editor. Click **Run** and verify that the results display customer data in the **Results** tab, confirming the data has been successfully migrated (50 rows returned).

	![Step 6.png](../../media/image54.png)


## What We Learned

- How to connect to and validate a migrated Azure SQL Database via Query Editor
- How to verify migrated database objects and dependencies
- How to validate data integrity and functionality after migration
- How to test views, stored procedures, and functions in the target environment
- How post-migration validation helps ensure trust in business-critical data

---

## Conclusion

You have successfully validated the migrated Azure SQL Database and confirmed that Zava's retail transaction data has been successfully modernized. By verifying database objects, validating data consistency, and testing database functionality, you ensured that the migrated environment is ready for business use. 

