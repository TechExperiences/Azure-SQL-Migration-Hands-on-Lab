# Exercise 3: Configure Azure Database Migration Service

The source and target database are now ready for migration. Before moving schema objects and data, a secure connection must be established between the on-premises SQL Server environment and Azure SQL Database. Azure Database Migration Service (DMS) provides the migration infrastructure required to enable this process.

In this exercise, you will review Azure Database Migration Service, install and register the Self-Hosted Integration Runtime, and validate connectivity via IR Authentication Key between the source and target systems. These steps ensure that the migration infrastructure is in place and ready to support the upcoming migration process.

## ✅ Outcome

- Azure Database Migration Service reviewed and validated
- Self-Hosted Integration Runtime successfully installed and registered
- Connectivity established between on-premises SQL Server and Azure SQL Database
- Migration infrastructure configured and operational
- Foundation established for executing the database migration

### Task 3.1: Review the Azure Database Migration Service​

### Task 3.2: Install and Register the Self-Hosted Integration Runtime​

### Task 3.3: Verify Connectivity Through the Integration Runtime

## What We Learned

- How Azure Database Migration Service supports SQL Server migration scenarios
- How to install and configure a Self-Hosted Integration Runtime
- How the Integration Runtime securely connects on-premises and Azure environments
- How to validate migration readiness before moving business-critical data
- How proper connectivity and infrastructure preparation reduce migration risk

## Next Exercise

In the next exercise, Mark will use the migration infrastructure configured here to migrate Zava's retail transaction database to Azure SQL Database. He will validate schema compatibility, transfer data, and confirm that the migrated environment is ready to support modern analytics and reporting workloads.

