# Real Estate Agency & Data Analytics Portfolio

A comprehensive PostgreSQL project featuring advanced database design, relational modeling, automated procedures, role-based security, and analytical queries.

---

## 🛠️ Tech Stack & Skills
* **Database Management:** PostgreSQL, PL/pgSQL
* **Database Design:** Relational Modeling, DDL/DML, Constraints, Foreign Key Cascades, Generated Stored Columns
* **Security & Access Control:** Role-Based Access Control (RBAC), Row-Level Security (RLS)
* **Advanced SQL:** Window Functions, Common Table Expressions (CTEs), Conditional Aggregations, Views, PL/pgSQL Functions

---

## 🏗️ Database Schema & Architecture

This project models a robust **Real Estate Agency** database schema containing entities for clients, agents, properties, transactions, financial records, and market tracking.

### Entity-Relationship (ER) Diagram
![ER Diagram](docs/schema.png)

### Key Schema Elements:
* **Core Entities:** `users` / `client`, `agent`, `role`, `user_role`, `product` / `properties`, `product_categories` / `client_addresses`.
* **Operations & Tracking:** `orders`, `order_items`, `shipments`, `transactions`, `financerecord`, `market_data`.
* **Data Integrity Features:** 
  * Strict check constraints on non-negative pricing, future date enforcement, and valid client types.
  * Generated columns for automated income calculations (`agency_fee + commission`).
  * Referential integrity with `ON DELETE CASCADE` and `ON DELETE SET NULL` rules.

---

## 📂 Repository Structure
```text
├── sql/
│   ├── schema_setup.sql          # Database, schemas, tables, and constraints DDL
│   ├── seed_data.sql             # Initial data insertion and updates (DML)
│   ├── functions_and_views.sql   # PL/pgSQL functions, procedures, and analytics views
│   └── security_and_rls.sql      # Roles, permissions, and Row-Level Security policies
├── docs/
│   └── schema.png                # Database ER Diagram
└── README.md
