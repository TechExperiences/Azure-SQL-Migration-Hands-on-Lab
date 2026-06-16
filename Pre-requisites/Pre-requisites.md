# Prerequisites for On-Prem SQL Server to Azure SQL Database Migration – Hands-on Lab
 
## Azure Access Requirements
 
Participants should have:
 
* An active Azure subscription.
* Contributor (or higher) access to the provided Azure Resource Group.
* Permission to create and manage Azure Database Migration Service (DMS) migration projects.
 
---
 
## Required Software (Pre-installed on Participant Workstation)
 
The following software must be installed and configured on the participant's local machine **before** starting the lab.
 
 
| Software                                  | Purpose                                                  | Download Link |
| ----------------------------------------- | -------------------------------------------------------- | ------------- |
| SQL Server 2025 (Enterprise Developer edition) | Hosts the on-prem source database to be migrated         | [Download SQL Server 2025](https://go.microsoft.com/fwlink/?linkid=2344711&clcid=0x4009&culture=en-in&country=in) |
| SQL Server Management Studio (SSMS)       | Connects to and manages the source SQL Server instance   | [Download SSMS](https://aka.ms/ssms/22/release/vs_SSMS.exe) |
| Self-Hosted Integration Runtime           | Securely connects on-premises SQL Server to Azure DMS    | [Download Microsoft Integration Runtime](https://www.microsoft.com/en-us/download/details.aspx?id=39717) |
 
---
 
## Lab Environment
 
The following Azure resources are **pre-provisioned** and available before starting the lab.
 
### Azure SQL Resources
 
| Resource                       | Purpose                   |
| ------------------------------ | ------------------------- |
| Azure SQL Logical Server       | Target SQL Server         |
| Azure SQL Database (`salesdb`) | Target migration database |
 
---
 
### Azure Database Migration Service
 
The following resource has already been provisioned:
 
| Resource                               | Purpose                                                                               |
| -------------------------------------- | ------------------------------------------------------------------------------------- |
| Azure Database Migration Service (DMS) | Database migration service used to migrate SQL Server databases to Azure SQL Database |

> **Note:** The Azure Database Migration Service must be provisioned with a **Virtual Network (VNET)** and **Subnet** configuration to enable secure connectivity between the on-premises SQL Server environment and Azure SQL Database.

### Networking Resources

The following networking resources are pre-provisioned to support DMS connectivity:

| Resource                       | Purpose                                                              |
| ------------------------------ | -------------------------------------------------------------------- |
| Virtual Network (VNET)         | Provides network isolation and secure communication for DMS          |
| Subnet (dedicated for DMS)     | Dedicated subnet within the VNET for Azure Database Migration Service |
 
---
 
 
## Required Credentials
 
### SQL Server
 
* SQL Authentication Username
* SQL Authentication Password

### Self-Hosted Integration Runtime

* IR Authentication Key (obtained from Azure Database Migration Service)

    > **Note:** The IR Authentication Key can be obtained from the Azure Database Migration Service while creating a new migration, under **Configure runtime settings** in the Configure integration runtime panel.

    ![Step 7.png](../Lab/media/image32.png)


 
---
 
 
# Azure Resources Used in this Lab
 
| Azure Resource                         | Purpose                                                    |
| -------------------------------------- | ---------------------------------------------------------- |
| Azure SQL Database                     | Migration target                                           |
| Azure SQL Logical Server               | Hosts Azure SQL Database                                   |
| Azure Database Migration Service (DMS) | Performs offline database migration                        |
| Virtual Network (VNET)                 | Provides network isolation and secure connectivity for DMS |
| Subnet                                 | Dedicated subnet for DMS within the VNET                   |
| Self-Hosted Integration Runtime        | Securely connects SQL Server to Azure DMS                  |
 


---
 
 
# Ready Check
 
Before beginning the lab, verify the following.
 
| Item                                                | Status |
| --------------------------------------------------- | ------ |
| Azure subscription is accessible                    | ✅      |
| SQL Server and SSMS are installed on the workstation | ✅      |
| Azure SQL Logical Server is provisioned             | ✅      |
| Azure SQL Database (`RetailsDB`) is available         | ✅      |
| Azure Database Migration Service (DMS) is available | ✅      |
| VNET and Subnet configured for DMS                  | ✅      |
| Required credentials have been provided             | ✅      |
| Self-Hosted Integration Runtime                     | ✅      |