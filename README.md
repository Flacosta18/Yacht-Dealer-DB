 Blue Water Yacht Dealers  Database Design Project

relational database for a yacht dealership covering vessel inventory, sales transactions, financing, employee management, service/maintenance orders, parts inventory, and marina mooring.



 Project Overview

Blue Water Yacht Dealers is a dealership management system designed to support:

 ''Vessel inventory''  manufacturer tracking, hull IDs, condition, pricing, and availability status
 
 ''Sales pipeline''  deals linking clients, vessels, and sales reps with tradein support
 
 ''Financing''  loan details, lender info, interest rates, and approval tracking per deal
 
 ''Employee management''  staff across Sales, Service, Finance, and Management departments with commission rates
 
 ''Client records''  individual and corporate buyers with referral tracking and experience level
 
 ''Service & maintenance''  full work orders assigned to technicians with promised dates and status tracking
 
 ''Parts inventory''  parts catalog with reorder alerts and cost/sell pricing
 
 ''Mooring management''  slip assignments for vessels currently in service



 Live ER Diagram

[View Interactive ER Diagram →](https://flacosta18.github.io/Yacht-Dealer-DB/yacht_dealer_er_diagram_workbench.html)



 Schema Summary

11 entities with defined primary and foreign key relationships:

 Table  Primary Key  Foreign Keys 

 `Manufacturer`  `manufacturer_id`   
 `Vessel`  `vessel_id`  `manufacturer_id` 
 `Department`  `department_id` 
 `Employee`  `employee_id`  `department_id` 
 `Client`  `client_id`  `referred_by` (selfref) 
 `Deal`  `deal_id`  `vessel_id`, `client_id`, `employee_id` 
 `Financing`  `financing_id`  `deal_id` 
 `Mooring`  `mooring_id`  `vessel_id` 
 `Part`  `part_id`  
 `Service_Order`  `service_order_id`  `vessel_id`, `client_id`, `assigned_tech_id`, `mooring_id` 
 `Service_Line`  `service_line_id`  `service_order_id`, `part_id` 



 Key Relationships

 One ''Manufacturer'' → Many ''Vessels'' (1:M)
 
 One ''Department'' → Many ''Employees'' (1:M)
 
 One ''Vessel'' → Many ''Deals'' (1:M)
 
 One ''Client'' → Many ''Deals'' (1:M)
 
 One ''Employee'' → Many ''Deals'' as sales rep (1:M)
 
 One ''Deal'' → One ''Financing'' plan (1:1)
 
 One ''Vessel'' → Many ''Service Orders'' (1:M)
 
 One ''Service Order'' → Many ''Service Lines'' (1:M)
 
 One ''Part'' → Many ''Service Lines'' (1:M)
 
 One ''Mooring'' → One active ''Vessel'' assignment (1:1)
 
 One ''Client'' → Many ''Client referrals'' (selfreferencing 1:M)






 How to Run

1. Open MySQL Workbench or any MySQL client
2. Run `sql/yacht_dealer_schema.sql`
3. Once you run script it will create the `blue_water_yachts` database with all 11 tables with constraints and foreign keys it will also insert sample data across all tables and execute 6 analytical queries demonstrating real business use cases.



 Sample Queries Included

1. ''Full sales report''  vessel, client, sales rep, net sale, and commission calculation
2. ''Open service orders''  technician assignments, mooring, and promised dates
3. ''Vessel inventory''  availability, condition, and pricing sorted by status
4. ''Sales rep performance''  closed deals, total revenue, and commission earned per rep
5. ''Parts reorder alert''  inventory items at or below reorder threshold
6. ''Service order cost breakdown''  parts used, labor, and totals per work order



 Tools & Technologies

 ''Database:'' MySQL
 
 ''Design:'' EntityRelationship Modeling, Normalization
 
 ''Notable features:'' Selfreferencing FK (client referrals), composite business logic (deal → financing 1:1), parts inventory with reorder logic, commission rate calculations



'Academic/portfolio project  Blue Water Yacht Dealers is a fictitious business scenario.'
