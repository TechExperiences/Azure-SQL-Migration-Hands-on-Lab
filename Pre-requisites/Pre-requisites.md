# Prerequisites for On-Prem SQL Server to Azure SQL Database Migration – Hands-on Lab

## Azure Access Requirements

Participants should have:

* An active Azure subscription.
* Contributor (or higher) access to the provided Azure Resource Group.
* Permission to create and manage Azure Database Migration Service (DMS) migration projects.

---

## Lab Environment

The following Azure resources are **pre-provisioned** and available before starting the lab.

### Azure Virtual Machine

The Azure VM represents the on-premises environment and will be used to host SQL Server.

| Resource              | Description                                      |
| --------------------- | ------------------------------------------------ |
| Azure Virtual Machine | Windows Server 2022                              |
| Purpose               | Simulates the on-premises SQL Server environment |

---

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

---


## Required Credentials

### Azure Virtual Machine

* Virtual Machine IP Address
* Username
* Password

### SQL Server

* SQL Authentication Username
* SQL Authentication Password

---


# Azure Resources Used in this Lab

| Azure Resource                         | Purpose                                   |
| -------------------------------------- | ----------------------------------------- |
| Azure Virtual Machine                  | Hosts the on-premises SQL Server          |
| Azure SQL Database                     | Migration target                          |
| Azure SQL Logical Server               | Hosts Azure SQL Database                  |
| Azure Database Migration Service (DMS) | Performs offline database migration       |
| Self-Hosted Integration Runtime        | Securely connects SQL Server to Azure DMS |

---


# Ready Check

Before beginning the lab, verify the following.

| Item                                                | Status |
| --------------------------------------------------- | ------ |
| Azure subscription is accessible                    | ✅      |
| Azure Virtual Machine is available                  | ✅      |
| Azure SQL Logical Server is provisioned             | ✅      |
| Azure SQL Database (`RetailsDB`) is available         | ✅      |
| Azure Database Migration Service (DMS) is available | ✅      |
| Required credentials have been provided             | ✅      |

 