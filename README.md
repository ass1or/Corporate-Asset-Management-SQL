# 🗄️ Corporate IT Asset & Identity Management System

## Project Overview
This project involves the design and implementation of a **relational database system** for managing IT assets, software licenses, and employee lifecycles in a corporate environment. [cite_start]The goal was to replace error-prone manual tracking (Excel) with a structured, ACID-compliant SQL solution[cite: 1].

The system not only stores data but actively enforces **business logic** through stored procedures, simulating real-world **IAM (Identity and Access Management)** workflows like automated onboarding and secure offboarding of employees.

## 🔐 Cybersecurity & Integrity Perspective
As an aspiring Security Engineer, I designed this database with **Data Integrity (CIA Triad)** and **Auditability** in mind:

* **Identity Lifecycle Management:** Implemented stored procedures (`OnboardNewEmployee`, `OffboardEmployee`) to automate the provisioning and de-provisioning of assets. [cite_start]This reduces human error and ensures that terminated employees instantly lose association with company assets[cite: 14, 15].
* [cite_start]**Data Integrity & Constraints:** Used foreign keys with `ON DELETE SET NULL/CASCADE` rules to prevent "orphaned records" and ensure that sensitive asset data is always linked to a valid owner or department[cite: 5, 6].
* [cite_start]**Normalization (3NF):** The database follows strict 3rd Normal Form standards to eliminate redundancy and data anomalies, ensuring a "Single Source of Truth"[cite: 7, 9].
* [cite_start]**Engine Hardening:** Forced usage of `InnoDB` engine to ensure transaction reliability and row-level locking[cite: 16].

## 🛠️ Tech Stack
* **Database:** MySQL
* **Language:** SQL (DDL, DML, Stored Procedures, Triggers)
* **Design Tool:** ERD (Entity Relationship Diagram)
* **Key Concepts:** Normalization (1NF-3NF), ACID, Relational Integrity.

## 📊 Database Schema (ERD)
[cite_start]The system is built on 7 interconnected tables, separating logic for Departments, Employees, Devices, and Software Licenses[cite: 3].

![Database Diagram](Diagram%20ERD.png)
*(Entity Relationship Diagram showing 1:1, 1:M, and M:M relationships)*

## ⚙️ Key Features & Code Snippets

### 1. Automated Onboarding (IAM Simulation)
[cite_start]A stored procedure that automatically creates an employee profile and assigns an available laptop from the "In Stock" pool, ensuring immediate operational readiness[cite: 14].

```sql
CREATE PROCEDURE OnboardNewEmployee(...)
BEGIN
    -- 1. Create User Profile
    INSERT INTO employees (...) VALUES (...);
    
    -- 2. Asset Provisioning (Find available laptop)
    SELECT id INTO v_laptop_id FROM devices 
    WHERE status = 'In Stock' LIMIT 1;

    -- 3. Assign Asset
    UPDATE devices SET assigned_emp = v_new_emp_id ...
END




2. Secure Offboarding (Revoking Access)
Security-critical procedure. When an employee is terminated, the system automatically reclaims their assets back to the warehouse inventory, preventing equipment loss.

SQL

CREATE PROCEDURE OffboardEmployee(IN p_email VARCHAR(100))
BEGIN
    -- Return assets to stock (Revoke physical access)
    UPDATE devices 
    SET status = 'In Stock', assigned_emp = NULL 
    WHERE assigned_emp = v_emp_id;

    -- Remove user identity
    DELETE FROM employees WHERE emp_id = v_emp_id;
END




3. Financial Reporting View
A dynamic view v_leasing_report allows the IT/Finance department to audit monthly costs per cost center.

SQL

CREATE VIEW v_leasing_report AS
SELECT d.model_name, l.paying_entity, l.monthly_cost_pln
FROM devices d
JOIN lease_info l ON d.id = l.device_id;


---
🚀 How to Run
1.Clone the repository.

2. Import corporate_assets.sql into your MySQL server.

3. Run the test procedures located at the bottom of the SQL file to simulate employee hiring/firing.
