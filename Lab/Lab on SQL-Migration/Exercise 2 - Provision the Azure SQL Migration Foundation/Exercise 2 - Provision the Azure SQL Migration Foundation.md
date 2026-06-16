# Exercise 2: Provision the Azure SQL Migration Foundation

Mark has successfully prepared Zava's on-premises SQL Server environment and loaded the retail transaction data that will be migrated as part of the company's modernization initiative.

Before any migration can begin, Mark must ensure that the target Azure environment is properly configured and ready to receive production data. A successful migration depends not only on moving data, but also on establishing secure connectivity, validating access, and confirming that the destination environment is prepared for the migration process.

In this exercise, Mark reviews the pre-provisioned Azure SQL resources, verifies network connectivity between the on-premises environment and Azure, and confirms that the target database is ready to receive migrated data. These steps establish the migration foundation required for the next phase of Zava's cloud modernization journey.

## ✅ Outcome
- Azure SQL Logical Server and Azure SQL Database reviewed and validated
- Firewall rules configured to enable secure connectivity
- Database connectivity verified through the Azure Portal Query Editor
- Target Azure SQL Database confirmed ready for migration
- Cloud migration foundation established for the next phase of modernization


### Task 2.1: Access the Provided Azure SQL Server and Database​

1. Click on the **Microsoft Edge** browser icon on the taskbar, navigate to the Azure Portal by entering the following URL in the address bar, and then click on the **Search bar** at the top of the page.

    ```text
    portal.azure.com
    ```

    ![Step 1.png](../../media/image19.png)

2. In the Search bar, type the following and click on **Resource Groups** from the search results.

    ```text
    Resource Groups
    ```

    ![Step 2.png](../../media/image20.png)

3. In the Resource Groups list, click on **rg-workIQ-Lab**.

    ![Step 3.png](../../media/image21.png)

4. In the resource group, click on **sql-rgworkiqlab-f1-06151713336** (Type: SQL server) from the Resources list.

    ![Step 4.png](../../media/image22.png)



### Task 2.2: Configure and Verify Firewall Rules​


5. On the SQL server page, in the left-hand search bar, type the following and click on **Networking** under Security.

    ```text
    networking
    ```

    ![Step 5.png](../../media/image23.png)

6. On the Networking page, under **Firewall rules**, click on **+ Add your client IPv4 address**. You will see your IP address added as a new firewall rule. Then click **Save**.

    ![Step 6.png](../../media/image24.png)

7. Wait for the notification popup confirming **"Successfully updated server firewall rules"** for server sql-rgworkiqlab-f1-06151713336.

    ![Step 7.png](../../media/image25.png)

### Task 2.3: Test Azure SQL Database Connection and Verify Empty State

8. In the left panel, expand **Settings** and click on **SQL databases**. Then click on **sqldb-rgworkiqlab-f1-06151713336** from the database list.

    ![Step 8.png](../../media/image26.png)

9. In the left panel, click on **Query editor (preview)**. In the Query editor login page, select **SQL Server authentication**, enter the following credentials, and click **OK**.

    - **Login**:

        ```text
       
        ```

    - **Password**:

        ```text
        
        ```

    ![Step 9.png](../../media/image27.png)

10. In the **Explorer** section on the left, expand **sqldb-rgworkiqlab-f1-0...** > **dbo** to verify the database structure. You can see **Tables**, **Views**, **Stored Procedures**, and **Functions** listed under the dbo schema, confirming the database is empty and ready for migration.

    ![Step 10.png](../../media/image28.png)



## What We Learned

- How to review and validate Azure SQL migration resources
- How to configure firewall rules to enable secure database connectivity
- How to connect to Azure SQL Database using the Azure Portal Query Editor
- How to verify that a target database is prepared for migration
- How proper environment preparation reduces migration risk and improves reliability

## Next Exercise

In the next exercise, Mark begins migrating Zava's retail transaction data from the on-premises SQL Server environment to Azure SQL Database. He will generate migration artifacts, validate schema compatibility, and perform the data migration to establish a modern, cloud-based data platform that supports future analytics and AI initiatives.

