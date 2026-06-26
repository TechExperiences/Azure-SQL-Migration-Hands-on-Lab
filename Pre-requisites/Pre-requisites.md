# Prerequisites for On-Prem SQL Server to Azure SQL Database-Hyperscale Migration – Hands-on Lab
 
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
| Visual Studio Code - Insiders             | Development environment for database migration and AI-assisted coding | [Download VS Code Insiders](https://code.visualstudio.com/insiders/) |
| Self-Hosted Integration Runtime           | Securely connects on-premises SQL Server to Azure DMS    | [Download Microsoft Integration Runtime](https://www.microsoft.com/en-us/download/details.aspx?id=39717) |

### Required VS Code Extensions

The following extensions must be installed in Visual Studio Code - Insiders:

| Extension                     | Purpose                                                     | Installation |
| ----------------------------- | ----------------------------------------------------------- | ------------ |
| GitHub Copilot Chat           | Provides AI-powered assistance for database migration tasks | Install from VS Code Extensions Marketplace |
| SQL Server (mssql)            | Connects to SQL Server databases and executes queries       | Install from VS Code Extensions Marketplace |

> **Note:** To install extensions, open VS Code Insiders, press `Ctrl+Shift+X` to open the Extensions view, search for each extension by name, and click **Install**.
 
---

## On-Premises Database Setup

A 📦 .zip folder containing database setup files is provided for this lab. This folder includes:

* **📄 SQL files (.sql)**: Contains the schema and data scripts required to set up the source database on your on-premises SQL Server.
* **⚙️ Batch file (.bat)**: Contains automated commands to execute the database setup.

### Setup Instructions

1. Extract the provided 📦 `.zip` folder to a local directory on your workstation.
2. Locate the ⚙️ `.bat` file inside the extracted folder.
3. Right-click the ⚙️ `.bat` file and select **Run as Administrator**.
4. The on-premises database setup will automatically complete.

> **Important:** Ensure SQL Server is running and SQL Server Authentication is enabled before executing the batch file.

---
 
## Lab Environment
 
The following Azure resources are **pre-provisioned** and available before starting the lab.
 
### Azure SQL Resources
 
| Resource                       | Purpose                   |
| ------------------------------ | ------------------------- |
| Azure SQL Logical Server       | Target SQL Server         |
| Azure SQL Database-Hyperscale (`salesdb`) | Target migration database |
 
---
 
### Azure Database Migration Service
 
The following resource has already been provisioned:
 
| Resource                               | Purpose                                                                               |
| -------------------------------------- | ------------------------------------------------------------------------------------- |
| Azure Database Migration Service (DMS) | Database migration service used to migrate SQL Server databases to Azure SQL Database-Hyperscale |

> **Note:** The Azure Database Migration Service must be provisioned with a **Virtual Network (VNET)** and **Subnet** configuration to enable secure connectivity between the on-premises SQL Server environment and Azure SQL Database-Hyperscale.

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

### GitHub Account

* A GitHub account with **GitHub Copilot Enterprise** enabled

    > **Note:** GitHub Copilot Enterprise is required to access AI-powered features in VS Code during the validation and comparison tasks.

### Self-Hosted Integration Runtime

* IR Authentication Key (obtained from Azure Database Migration Service)

    > **Note:** The IR Authentication Key can be obtained from the Azure Database Migration Service while creating a new migration, under **Configure runtime settings** in the Configure integration runtime panel.

    ![Step 7.png](../Lab/media/image32.png)


 
---
 
 
# Azure Resources Used in this Lab
 
| Azure Resource                         | Purpose                                                    |
| -------------------------------------- | ---------------------------------------------------------- |
| Azure SQL Database-Hyperscale                     | Migration target                                           |
| Azure SQL Logical Server               | Hosts Azure SQL Database-Hyperscale                                   |
| Azure Database Migration Service (DMS) | Performs offline database migration                        |
| Virtual Network (VNET)                 | Provides network isolation and secure connectivity for DMS |
| Subnet                                 | Dedicated subnet for DMS within the VNET                   |
| Self-Hosted Integration Runtime        | Securely connects SQL Server to Azure DMS                  |
 


---
 
 
# Ready Check
 
Before beginning the lab, verify the following.
 
| Item                                                         | Status |
| ------------------------------------------------------------ | ------ |
| Azure subscription is accessible                             | ✅      |
| SQL Server and SSMS are installed on the workstation          | ✅      |
| VS Code Insiders with GitHub Copilot Chat and SQL Server extensions installed | ✅      |
| On-premises database has been set up using .bat file          | ✅      |
| Azure SQL Logical Server is provisioned                      | ✅      |
| Azure SQL Database-Hyperscale (`RetailsDB`) is available     | ✅      |
| Azure Database Migration Service (DMS) is available          | ✅      |
| VNET and Subnet configured for DMS                           | ✅      |
| GitHub account with GitHub Copilot Enterprise enabled | ✅      |
| Required credentials have been provided                      | ✅      |
| Self-Hosted Integration Runtime installed and configured     | ✅      |
