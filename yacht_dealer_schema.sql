-- ============================================================
--  Blue Water Yacht Dealers — Database Schema
--  Author: Bon
--  Description: Full operational relational database for a
--               yacht dealership covering vessel inventory,
--               sales, financing, staff, service/maintenance,
--               parts, and mooring management.
-- ============================================================

CREATE DATABASE IF NOT EXISTS blue_water_yachts;
USE blue_water_yachts;

-- ------------------------------------------------------------
-- MANUFACTURER
-- ------------------------------------------------------------
CREATE TABLE Manufacturer (
    manufacturer_id     INT           NOT NULL AUTO_INCREMENT,
    manufacturer_name   VARCHAR(50)   NOT NULL,
    country_of_origin   VARCHAR(30),
    website             VARCHAR(100),
    contact_phone       CHAR(10),
    contact_email       VARCHAR(50),
    PRIMARY KEY (manufacturer_id)
);

-- ------------------------------------------------------------
-- VESSEL
-- ------------------------------------------------------------
CREATE TABLE Vessel (
    vessel_id           INT           NOT NULL AUTO_INCREMENT,
    manufacturer_id     INT           NOT NULL,
    model               VARCHAR(50)   NOT NULL,
    year                YEAR          NOT NULL,
    vessel_type         VARCHAR(30)   NOT NULL,  -- Sailboat, Motor Yacht, Catamaran, etc.
    length_ft           DECIMAL(5,1),
    hull_material       VARCHAR(20),
    engine_count        TINYINT,
    engine_hp           INT,
    condition_status    VARCHAR(10)   NOT NULL,  -- New, Used, Certified
    list_price          DECIMAL(12,2) NOT NULL,
    vin_hull_id         VARCHAR(30)   UNIQUE,
    availability_status VARCHAR(15)   NOT NULL DEFAULT 'Available', -- Available, Sold, In Service
    date_acquired       DATE,
    notes               TEXT,
    PRIMARY KEY (vessel_id),
    CONSTRAINT fk_vessel_mfr FOREIGN KEY (manufacturer_id)
        REFERENCES Manufacturer(manufacturer_id)
);

-- ------------------------------------------------------------
-- DEPARTMENT
-- ------------------------------------------------------------
CREATE TABLE Department (
    department_id       INT           NOT NULL AUTO_INCREMENT,
    department_name     VARCHAR(30)   NOT NULL,
    department_budget   DECIMAL(12,2),
    PRIMARY KEY (department_id)
);

-- ------------------------------------------------------------
-- EMPLOYEE
-- ------------------------------------------------------------
CREATE TABLE Employee (
    employee_id         INT           NOT NULL AUTO_INCREMENT,
    department_id       INT,
    first_name          VARCHAR(20)   NOT NULL,
    last_name           VARCHAR(20)   NOT NULL,
    job_title           VARCHAR(30)   NOT NULL,
    hire_date           DATE          NOT NULL,
    termination_date    DATE,
    salary              DECIMAL(10,2),
    commission_rate     DECIMAL(4,3),             -- e.g. 0.035 = 3.5%
    phone               CHAR(10),
    email               VARCHAR(50)   NOT NULL,
    certifications      VARCHAR(100),
    PRIMARY KEY (employee_id),
    CONSTRAINT fk_emp_dept FOREIGN KEY (department_id)
        REFERENCES Department(department_id)
);

-- ------------------------------------------------------------
-- CLIENT
-- ------------------------------------------------------------
CREATE TABLE Client (
    client_id           INT           NOT NULL AUTO_INCREMENT,
    first_name          VARCHAR(20)   NOT NULL,
    last_name           VARCHAR(20)   NOT NULL,
    client_type         VARCHAR(15)   NOT NULL DEFAULT 'Individual', -- Individual, Corporate
    company_name        VARCHAR(50),
    street1             VARCHAR(40)   NOT NULL,
    street2             VARCHAR(40),
    city                VARCHAR(30)   NOT NULL,
    state               CHAR(2)       NOT NULL,
    zip                 CHAR(5)       NOT NULL,
    phone               CHAR(10)      NOT NULL,
    email               VARCHAR(50)   NOT NULL,
    boating_experience  VARCHAR(15),              -- Beginner, Intermediate, Expert
    referred_by         INT,                      -- FK to another client_id
    date_added          DATE          NOT NULL,
    PRIMARY KEY (client_id),
    CONSTRAINT fk_client_referral FOREIGN KEY (referred_by)
        REFERENCES Client(client_id)
);

-- ------------------------------------------------------------
-- DEAL  (Sales Transaction)
-- ------------------------------------------------------------
CREATE TABLE Deal (
    deal_id             INT           NOT NULL AUTO_INCREMENT,
    vessel_id           INT           NOT NULL,
    client_id           INT           NOT NULL,
    employee_id         INT           NOT NULL,   -- Sales rep
    deal_date           DATE          NOT NULL,
    sale_price          DECIMAL(12,2) NOT NULL,
    trade_in_value      DECIMAL(12,2) DEFAULT 0,
    deal_status         VARCHAR(15)   NOT NULL DEFAULT 'Pending', -- Pending, Closed, Cancelled
    closing_date        DATE,
    notes               TEXT,
    PRIMARY KEY (deal_id),
    CONSTRAINT fk_deal_vessel   FOREIGN KEY (vessel_id)   REFERENCES Vessel(vessel_id),
    CONSTRAINT fk_deal_client   FOREIGN KEY (client_id)   REFERENCES Client(client_id),
    CONSTRAINT fk_deal_employee FOREIGN KEY (employee_id) REFERENCES Employee(employee_id)
);

-- ------------------------------------------------------------
-- FINANCING
-- ------------------------------------------------------------
CREATE TABLE Financing (
    financing_id        INT           NOT NULL AUTO_INCREMENT,
    deal_id             INT           NOT NULL UNIQUE,  -- One financing plan per deal
    lender_name         VARCHAR(50)   NOT NULL,
    loan_amount         DECIMAL(12,2) NOT NULL,
    down_payment        DECIMAL(12,2) NOT NULL,
    interest_rate       DECIMAL(5,3)  NOT NULL,         -- e.g. 6.250
    term_months         SMALLINT      NOT NULL,
    monthly_payment     DECIMAL(10,2),
    approval_date       DATE,
    approval_status     VARCHAR(15)   NOT NULL DEFAULT 'Pending',
    PRIMARY KEY (financing_id),
    CONSTRAINT fk_financing_deal FOREIGN KEY (deal_id) REFERENCES Deal(deal_id)
);

-- ------------------------------------------------------------
-- MOORING  (Slip/Dock assignment for service vessels)
-- ------------------------------------------------------------
CREATE TABLE Mooring (
    mooring_id          INT           NOT NULL AUTO_INCREMENT,
    slip_number         VARCHAR(10)   NOT NULL UNIQUE,
    dock_section        VARCHAR(10),
    length_capacity_ft  DECIMAL(5,1),
    daily_rate          DECIMAL(8,2),
    is_occupied         BOOLEAN       NOT NULL DEFAULT FALSE,
    vessel_id           INT,                      -- Currently assigned vessel
    PRIMARY KEY (mooring_id),
    CONSTRAINT fk_mooring_vessel FOREIGN KEY (vessel_id) REFERENCES Vessel(vessel_id)
);

-- ------------------------------------------------------------
-- PART  (Parts & supplies inventory)
-- ------------------------------------------------------------
CREATE TABLE Part (
    part_id             INT           NOT NULL AUTO_INCREMENT,
    part_number         VARCHAR(30)   NOT NULL UNIQUE,
    part_name           VARCHAR(60)   NOT NULL,
    category            VARCHAR(30),              -- Engine, Electrical, Hull, Navigation, etc.
    unit_cost           DECIMAL(10,2) NOT NULL,
    sell_price          DECIMAL(10,2) NOT NULL,
    qty_on_hand         INT           NOT NULL DEFAULT 0,
    reorder_level       INT           NOT NULL DEFAULT 5,
    supplier_name       VARCHAR(50),
    PRIMARY KEY (part_id)
);

-- ------------------------------------------------------------
-- SERVICE ORDER
-- ------------------------------------------------------------
CREATE TABLE Service_Order (
    service_order_id    INT           NOT NULL AUTO_INCREMENT,
    vessel_id           INT           NOT NULL,
    client_id           INT           NOT NULL,
    assigned_tech_id    INT           NOT NULL,   -- Employee (technician)
    mooring_id          INT,                      -- Slip assigned during service
    order_date          DATE          NOT NULL,
    promised_date       DATE,
    completion_date     DATE,
    service_type        VARCHAR(20)   NOT NULL,   -- Routine, Repair, Inspection, Winterize
    order_status        VARCHAR(15)   NOT NULL DEFAULT 'Open', -- Open, In Progress, Complete
    labor_hours         DECIMAL(6,2),
    labor_rate          DECIMAL(8,2),
    total_parts_cost    DECIMAL(10,2) DEFAULT 0,
    total_labor_cost    DECIMAL(10,2) DEFAULT 0,
    total_cost          DECIMAL(10,2) DEFAULT 0,
    notes               TEXT,
    PRIMARY KEY (service_order_id),
    CONSTRAINT fk_so_vessel   FOREIGN KEY (vessel_id)        REFERENCES Vessel(vessel_id),
    CONSTRAINT fk_so_client   FOREIGN KEY (client_id)        REFERENCES Client(client_id),
    CONSTRAINT fk_so_tech     FOREIGN KEY (assigned_tech_id) REFERENCES Employee(employee_id),
    CONSTRAINT fk_so_mooring  FOREIGN KEY (mooring_id)       REFERENCES Mooring(mooring_id)
);

-- ------------------------------------------------------------
-- SERVICE LINE  (Parts used on a Service Order)
-- ------------------------------------------------------------
CREATE TABLE Service_Line (
    service_line_id     INT           NOT NULL AUTO_INCREMENT,
    service_order_id    INT           NOT NULL,
    part_id             INT           NOT NULL,
    quantity_used       INT           NOT NULL DEFAULT 1,
    unit_price          DECIMAL(10,2) NOT NULL,
    line_total          DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (service_line_id),
    CONSTRAINT fk_sl_order FOREIGN KEY (service_order_id) REFERENCES Service_Order(service_order_id),
    CONSTRAINT fk_sl_part  FOREIGN KEY (part_id)          REFERENCES Part(part_id)
);


-- ============================================================
-- SAMPLE DATA
-- ============================================================

INSERT INTO Manufacturer (manufacturer_name, country_of_origin, contact_email) VALUES
    ('Azimut',       'Italy',         'info@azimut.com'),
    ('Beneteau',     'France',        'info@beneteau.com'),
    ('Sea Ray',      'USA',           'info@searay.com'),
    ('Sunseeker',    'UK',            'info@sunseeker.com'),
    ('Leopard',      'South Africa',  'info@leopardcatamarans.com');

INSERT INTO Department (department_name, department_budget) VALUES
    ('Sales',        250000.00),
    ('Service',      180000.00),
    ('Finance',      120000.00),
    ('Management',   300000.00);

INSERT INTO Employee (department_id, first_name, last_name, job_title, hire_date, salary, commission_rate, phone, email) VALUES
    (1, 'Carlos',  'Mendez',   'Senior Sales Consultant', '2019-03-15', 62000.00, 0.035, '3051110001', 'cmendez@bwyachts.com'),
    (1, 'Ashley',  'Thornton', 'Sales Consultant',        '2021-07-01', 52000.00, 0.030, '3051110002', 'athornton@bwyachts.com'),
    (2, 'Marco',   'Reyes',    'Lead Technician',         '2018-01-10', 68000.00, NULL,  '3051110003', 'mreyes@bwyachts.com'),
    (2, 'Diana',   'Chu',      'Marine Technician',       '2022-04-20', 55000.00, NULL,  '3051110004', 'dchu@bwyachts.com'),
    (4, 'Robert',  'Harmon',   'General Manager',         '2015-06-01', 110000.00,0.010, '3051110005', 'rharmon@bwyachts.com');

INSERT INTO Vessel (manufacturer_id, model, year, vessel_type, length_ft, hull_material, engine_count, engine_hp, condition_status, list_price, vin_hull_id, date_acquired) VALUES
    (1, 'Azimut 55',         2023, 'Motor Yacht',  55.0, 'Fiberglass', 2, 1200, 'New',  1250000.00, 'AZI55XYZ2023001', '2023-01-15'),
    (2, 'Oceanis 46.1',      2022, 'Sailboat',     46.1, 'Fiberglass', 1,  50,  'Used',  189000.00, 'BEN461ABC2022002', '2022-06-10'),
    (3, 'Sea Ray 320',       2024, 'Bowrider',     32.0, 'Fiberglass', 2,  600, 'New',   125000.00, 'SRY320DEF2024003', '2024-02-01'),
    (4, 'Sunseeker Predator',2021, 'Sport Cruiser',68.0, 'Fiberglass', 3, 1800, 'Used', 2100000.00, 'SSK68GHI2021004',  '2023-09-20'),
    (5, 'Leopard 45',        2023, 'Catamaran',    45.0, 'Fiberglass', 2,   80, 'New',   699000.00, 'LEO45JKL2023005',  '2023-11-05');

INSERT INTO Client (first_name, last_name, client_type, street1, city, state, zip, phone, email, boating_experience, date_added) VALUES
    ('James',    'Whitfield', 'Individual', '100 Ocean Dr',     'Miami',         'FL', '33139', '3059990001', 'jwhitfield@email.com', 'Expert',       '2023-02-10'),
    ('Sofia',    'Navarro',   'Individual', '250 Brickell Ave', 'Miami',         'FL', '33131', '3059990002', 'snavarro@email.com',   'Intermediate', '2023-05-22'),
    ('Harborview','Charters', 'Corporate',  '1 Marina Blvd',    'Fort Lauderdale','FL','33316', '9549990003', 'info@harborview.com',  'Expert',       '2022-11-01'),
    ('Derek',    'Fontaine',  'Individual', '88 Sunset Way',    'Key Largo',     'FL', '33037', '3059990004', 'dfontaine@email.com',  'Beginner',     '2024-01-15');

INSERT INTO Deal (vessel_id, client_id, employee_id, deal_date, sale_price, trade_in_value, deal_status, closing_date) VALUES
    (1, 1, 1, '2023-03-01', 1200000.00, 0.00,      'Closed',  '2023-03-15'),
    (2, 3, 2, '2023-07-10', 182000.00,  25000.00,  'Closed',  '2023-07-25'),
    (5, 2, 1, '2024-01-20', 680000.00,  0.00,      'Pending', NULL),
    (3, 4, 2, '2024-03-05', 122000.00,  0.00,      'Closed',  '2024-03-18');

INSERT INTO Financing (deal_id, lender_name, loan_amount, down_payment, interest_rate, term_months, monthly_payment, approval_status, approval_date) VALUES
    (1, 'Marine Finance Corp',    960000.00, 240000.00, 6.250, 180, 8230.50,  'Approved', '2023-03-10'),
    (2, 'SunTrust Marine Lending',137000.00,  45000.00, 7.100,  120,  1594.20, 'Approved', '2023-07-20'),
    (4, 'Blue Water Bank',         97600.00,  24400.00, 6.800,   84,  1491.30, 'Approved', '2024-03-15');

INSERT INTO Mooring (slip_number, dock_section, length_capacity_ft, daily_rate, is_occupied) VALUES
    ('A-01', 'A', 40.0,  85.00, FALSE),
    ('A-02', 'A', 55.0, 120.00, FALSE),
    ('B-01', 'B', 70.0, 175.00, FALSE),
    ('B-02', 'B', 50.0, 110.00, FALSE);

INSERT INTO Part (part_number, part_name, category, unit_cost, sell_price, qty_on_hand, reorder_level, supplier_name) VALUES
    ('ENG-OIL-15W40',  'Marine Engine Oil 15W-40 (qt)', 'Engine',     8.50,  14.99,  48, 10, 'West Marine'),
    ('ENG-FILTER-001', 'Oil Filter — Mercruiser',        'Engine',    12.00,  22.50,  20,  5, 'West Marine'),
    ('ELEC-BATT-AGM',  'AGM Marine Battery 100Ah',       'Electrical',145.00, 245.00,  8,  3, 'Batteries Plus'),
    ('HULL-ANTIFOUL',  'Antifouling Bottom Paint (gal)', 'Hull',       68.00, 110.00, 15,  4, 'Interlux'),
    ('NAV-VHF-IC',     'ICOM VHF Radio M330',            'Navigation', 189.00, 299.00,  5,  2, 'Marine Electronics Inc');

INSERT INTO Service_Order (vessel_id, client_id, assigned_tech_id, mooring_id, order_date, promised_date, completion_date, service_type, order_status, labor_hours, labor_rate, total_parts_cost, total_labor_cost, total_cost) VALUES
    (2, 3, 3, 1, '2024-02-01', '2024-02-05', '2024-02-04', 'Routine',    'Complete',    4.0, 125.00,  95.48,  500.00,  595.48),
    (1, 1, 4, 2, '2024-03-10', '2024-03-20', NULL,         'Repair',     'In Progress', NULL,125.00,   0.00,    0.00,    0.00),
    (3, 4, 3, 4, '2024-04-01', '2024-04-03', '2024-04-03', 'Inspection', 'Complete',    2.5, 125.00, 245.00,  312.50,  557.50);

INSERT INTO Service_Line (service_order_id, part_id, quantity_used, unit_price, line_total) VALUES
    (1, 1, 4, 14.99,  59.96),
    (1, 2, 1, 22.50,  22.50),
    (1, 4, 1, 110.00, 110.00),  -- Antifouling paint for annual bottom job
    (3, 3, 1, 245.00, 245.00);  -- Battery replacement on inspection


-- ============================================================
-- SAMPLE QUERIES
-- ============================================================

-- 1. Full sales report — vessel, client, rep, price, commission
SELECT
    d.deal_id,
    d.deal_date,
    d.closing_date,
    CONCAT(c.first_name, ' ', c.last_name)  AS client,
    CONCAT(e.first_name, ' ', e.last_name)  AS sales_rep,
    CONCAT(m.manufacturer_name, ' ', v.model, ' (', v.year, ')') AS vessel,
    d.sale_price,
    d.trade_in_value,
    d.sale_price - d.trade_in_value         AS net_sale,
    ROUND((d.sale_price - d.trade_in_value) * e.commission_rate, 2) AS rep_commission,
    d.deal_status
FROM Deal d
JOIN Vessel   v ON d.vessel_id   = v.vessel_id
JOIN Manufacturer m ON v.manufacturer_id = m.manufacturer_id
JOIN Client   c ON d.client_id   = c.client_id
JOIN Employee e ON d.employee_id = e.employee_id
ORDER BY d.deal_date DESC;

-- 2. Open service orders with assigned technician and mooring
SELECT
    so.service_order_id,
    so.order_date,
    so.promised_date,
    so.service_type,
    so.order_status,
    CONCAT(m.manufacturer_name, ' ', v.model) AS vessel,
    CONCAT(c.first_name, ' ', c.last_name)    AS client,
    CONCAT(e.first_name, ' ', e.last_name)    AS technician,
    mo.slip_number,
    so.total_cost
FROM Service_Order so
JOIN Vessel   v  ON so.vessel_id        = v.vessel_id
JOIN Manufacturer m ON v.manufacturer_id = m.manufacturer_id
JOIN Client   c  ON so.client_id        = c.client_id
JOIN Employee e  ON so.assigned_tech_id = e.employee_id
LEFT JOIN Mooring mo ON so.mooring_id   = mo.mooring_id
WHERE so.order_status != 'Complete'
ORDER BY so.promised_date;

-- 3. Vessel inventory with availability and pricing
SELECT
    v.vessel_id,
    m.manufacturer_name,
    v.model,
    v.year,
    v.vessel_type,
    v.length_ft,
    v.condition_status,
    v.availability_status,
    v.list_price,
    v.vin_hull_id
FROM Vessel v
JOIN Manufacturer m ON v.manufacturer_id = m.manufacturer_id
ORDER BY v.availability_status, v.list_price DESC;

-- 4. Sales rep performance summary
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS sales_rep,
    COUNT(d.deal_id)                        AS total_deals,
    SUM(CASE WHEN d.deal_status = 'Closed' THEN 1 ELSE 0 END) AS closed_deals,
    SUM(CASE WHEN d.deal_status = 'Closed' THEN d.sale_price ELSE 0 END) AS total_revenue,
    ROUND(SUM(CASE WHEN d.deal_status = 'Closed'
        THEN (d.sale_price - d.trade_in_value) * e.commission_rate ELSE 0 END), 2) AS total_commission
FROM Employee e
LEFT JOIN Deal d ON e.employee_id = d.employee_id
WHERE e.department_id = 1
GROUP BY e.employee_id
ORDER BY total_revenue DESC;

-- 5. Parts below reorder level (inventory alert)
SELECT
    part_number,
    part_name,
    category,
    qty_on_hand,
    reorder_level,
    reorder_level - qty_on_hand AS units_needed,
    supplier_name
FROM Part
WHERE qty_on_hand <= reorder_level
ORDER BY units_needed DESC;

-- 6. Service order cost breakdown with parts detail
SELECT
    so.service_order_id,
    CONCAT(m.manufacturer_name, ' ', v.model) AS vessel,
    p.part_name,
    sl.quantity_used,
    sl.unit_price,
    sl.line_total,
    so.labor_hours,
    so.labor_rate,
    so.total_labor_cost,
    so.total_cost
FROM Service_Line sl
JOIN Service_Order so ON sl.service_order_id = so.service_order_id
JOIN Part          p  ON sl.part_id          = p.part_id
JOIN Vessel        v  ON so.vessel_id        = v.vessel_id
JOIN Manufacturer  m  ON v.manufacturer_id   = m.manufacturer_id
ORDER BY so.service_order_id;
