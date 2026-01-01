-- ==========================================================
-- Project: Database "Corporate IT Assets""
-- Author: Aleksander Szłapka
-- ==========================================================

DROP DATABASE IF EXISTS CorpInventoryDB;
CREATE DATABASE CorpInventoryDB;
USE CorpInventoryDB;


-- ==========================================================
--  Database Structure
-- ==========================================================


CREATE TABLE departments (
  dep_id INT NOT NULL AUTO_INCREMENT,
  dep_name VARCHAR(50) NOT NULL,
  cost_center_code VARCHAR(10) NOT NULL,
  PRIMARY KEY (dep_id)
) ENGINE=InnoDB; -- defined new engine 


CREATE TABLE employees (
  emp_id INT NOT NULL AUTO_INCREMENT,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  email VARCHAR(100) NOT NULL,
  position VARCHAR(50),
  dep_id INT,
  PRIMARY KEY (emp_id),
  UNIQUE KEY (email),
  FOREIGN KEY (dep_id) REFERENCES departments(dep_id) ON DELETE SET NULL
) ENGINE=InnoDB;


CREATE TABLE devices (
  id INT NOT NULL AUTO_INCREMENT,
  serial_number VARCHAR(50) NOT NULL,
  asset_id VARCHAR(20) NOT NULL,
  model_name VARCHAR(100) NOT NULL,
  type ENUM('Laptop', 'Router', 'Switch', 'Printer') DEFAULT 'Laptop',
  
  -- Owners logic
  assigned_emp INT,    -- For laptops and nework devices (admins)
  assigned_dep INT,    -- For Printers (Department owner)
  
  status ENUM('In Use', 'In Stock', 'Service') DEFAULT 'In Use',
  is_shared_printer BOOLEAN DEFAULT FALSE, -- Is a shared printer?
  
  PRIMARY KEY (id),
  UNIQUE KEY (serial_number),
  UNIQUE KEY (asset_id),
  FOREIGN KEY (assigned_emp) REFERENCES employees(emp_id) ON DELETE SET NULL,
  FOREIGN KEY (assigned_dep) REFERENCES departments(dep_id) ON DELETE SET NULL
) ENGINE=InnoDB;




CREATE TABLE lease_info (
  device_id INT NOT NULL,
  provider_name VARCHAR(50) NOT NULL,
  contract_number VARCHAR(50) NOT NULL,
  monthly_cost_pln DECIMAL(10, 2),
  refresh_date DATE NOT NULL,
  paying_entity VARCHAR(50), -- who must pay
  PRIMARY KEY (device_id),
  FOREIGN KEY (device_id) REFERENCES devices(id) ON DELETE CASCADE
) ENGINE=InnoDB;



CREATE TABLE software_catalog (
  soft_id INT NOT NULL AUTO_INCREMENT,
  soft_name VARCHAR(100) NOT NULL,
  vendor VARCHAR(50),
  PRIMARY KEY (soft_id)
) ENGINE=InnoDB;

-- 6. Software Licesnse for employee (Relation M:M)
CREATE TABLE employee_software (
  emp_id INT NOT NULL,
  soft_id INT NOT NULL,
  assigned_at DATE DEFAULT (CURRENT_DATE),
  PRIMARY KEY (emp_id, soft_id),
  FOREIGN KEY (emp_id) REFERENCES employees(emp_id) ON DELETE CASCADE,
  FOREIGN KEY (soft_id) REFERENCES software_catalog(soft_id) ON DELETE CASCADE
) ENGINE=InnoDB;



CREATE TABLE repairs (
  repair_id BIGINT NOT NULL AUTO_INCREMENT,
  device_id INT NOT NULL,
  description TEXT,
  repair_cost DECIMAL(10,2) DEFAULT 0.00,
  repair_date DATETIME DEFAULT NOW(),
  PRIMARY KEY (repair_id),
  FOREIGN KEY (device_id) REFERENCES devices(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ==========================================================
--  Example database data 
-- ==========================================================

-- 1. 11 departments
INSERT INTO departments (dep_name, cost_center_code) VALUES 
('Zarząd', 'HQ-00'),
('IT', 'IT-01'),
('Logistyka', 'LOG-01'),
('Marketing', 'MKT-01'),
('DOK', 'CS-01'),
('Call Center', 'CC-01'),
('Prowizje', 'FIN-01'),
('Szkolenia', 'EDU-01'),
('HR', 'HR-01'),
('Administracja', 'ADM-01'),
('Recepcja', 'REC-01');

-- 2. 20 employees
INSERT INTO employees (first_name, last_name, email, position, dep_id) VALUES 
-- Managment (2 people)
('Krzysztof', 'Krawczyk', 'k.krawczyk@corp.pl', 'CEO', 1),
('Anna', 'Jantar', 'a.jantar@corp.pl', 'CFO', 1),
-- IT (2 people - Admins)
('Tomasz', 'Anderson', 'neo@corp.pl', 'Network Admin', 2),
('Piotr', 'Mróz', 'p.mroz@corp.pl', 'SysAdmin', 2),
-- Logistic (2 people)
('Marek', 'Kondrat', 'm.kondrat@corp.pl', 'Kierownik', 3),
('Jan', 'Himilsbach', 'j.himilsbach@corp.pl', 'Magazynier', 3),
-- Marketing (2 poeple)
('Dorota', 'Wellman', 'd.wellman@corp.pl', 'Creative Dir', 4),
('Marcin', 'Prokop', 'm.prokop@corp.pl', 'Social Media', 4),
-- DOK (2 people)
('Martyna', 'Wojciechowska', 'm.woj@corp.pl', 'Obsługa', 5),
('Wojciech', 'Cejrowski', 'w.cej@corp.pl', 'Obsługa', 5),
-- Call Center (2 people)
('Kuba', 'Wojewódzki', 'k.woj@corp.pl', 'Telemarketer', 6),
('Magda', 'Gessler', 'm.ges@corp.pl', 'Telemarketer', 6),
-- Prowizje (2 people)
('Leszek', 'Balcerowicz', 'l.bal@corp.pl', 'Analityk', 7),
('Tadeusz', 'Mazowiecki', 't.maz@corp.pl', 'Księgowy', 7),
-- Szkolenia (2 people)
('Robert', 'Lewandowski', 'r.lew@corp.pl', 'Trener', 8),
('Iga', 'Świątek', 'i.swi@corp.pl', 'Trener', 8),
-- HR (2 people)
('Jolanta', 'Kwaśniewska', 'j.kwa@corp.pl', 'HR Manager', 9),
('Aleksander', 'Kwaśniewski', 'a.kwa@corp.pl', 'Rekruter', 9),
-- Administracja + Recepcja (2 people)
('Stanisław', 'Tym', 's.tym@corp.pl', 'Office Mgr', 10),
('Krystyna', 'Janda', 'k.jan@corp.pl', 'Recepcjonistka', 11);

-- ==========================================================
-- Asset Assigments 
-- ==========================================================

-- Varibales for admins
SET @admin1 = (SELECT emp_id FROM employees WHERE email='neo@corp.pl');
SET @admin2 = (SELECT emp_id FROM employees WHERE email='p.mroz@corp.pl');

-- 1. Enabled devices
-- Management (2 Mac's)
INSERT INTO devices (serial_number, asset_id, model_name, type, assigned_emp) VALUES
('SN-MAC-001', 'AST-001', 'MacBook Pro M3', 'Laptop', 1),
('SN-MAC-002', 'AST-002', 'MacBook Pro M3', 'Laptop', 2);

-- Rest company
INSERT INTO devices (serial_number, asset_id, model_name, type, assigned_emp)
SELECT 
    CONCAT('SN-LEN-', emp_id), 
    CONCAT('AST-10', emp_id), 
    'Lenovo ThinkPad T14 Gen 5', 
    'Laptop', 
    emp_id
FROM employees 
WHERE emp_id > 2;

-- 2. Network devices
INSERT INTO devices (serial_number, asset_id, model_name, type, assigned_emp) VALUES
('NET-SW-01', 'NET-001', 'Cisco Catalyst 9300', 'Switch', @admin1),
('NET-SW-02', 'NET-002', 'Cisco Catalyst 9300', 'Switch', @admin2),
('NET-RT-01', 'NET-003', 'Cisco ISR 4400', 'Router', @admin1);

-- 3. Backup assets (5 sztuk - 4 Lenovo, 1 Mac)
-- 2 in repair, 3 in a stock
INSERT INTO devices (serial_number, asset_id, model_name, type, status, assigned_emp) VALUES
('SN-SPARE-01', 'STK-001', 'Lenovo ThinkPad T14 Gen 5', 'Laptop', 'In Stock', NULL),
('SN-SPARE-02', 'STK-002', 'Lenovo ThinkPad T14 Gen 5', 'Laptop', 'In Stock', NULL),
('SN-SPARE-03', 'STK-003', 'Lenovo ThinkPad T14 Gen 5', 'Laptop', 'In Stock', NULL),
('SN-SPARE-04', 'SRV-001', 'Lenovo ThinkPad T14 Gen 5', 'Laptop', 'Service', NULL), -- repair
('SN-SPARE-05', 'SRV-002', 'MacBook Pro M3', 'Laptop', 'Service', NULL);          -- repair

-- 4. Printers

INSERT INTO devices (serial_number, asset_id, model_name, type, assigned_dep, is_shared_printer) VALUES
('PRN-REC-01', 'PRN-001', 'Ricoh IM C3000', 'Printer', 11, TRUE), -- Front Desk
('PRN-REC-02', 'PRN-002', 'Ricoh IM C3000', 'Printer', 11, TRUE), -- ReFront Desk
('PRN-IT-01', 'PRN-003', 'HP LaserJet Pro', 'Printer', 2, FALSE), -- IT
('PRN-HR-01', 'PRN-004', 'HP LaserJet Pro', 'Printer', 9, FALSE), -- HR
('PRN-MKT-01', 'PRN-005', 'HP LaserJet Pro', 'Printer', 4, FALSE), -- Marketing
('PRN-LOG-01', 'PRN-006', 'HP LaserJet Pro', 'Printer', 3, FALSE); -- Logistic


-- ==========================================================
--  LEASING (Auto coast generated)
-- ==========================================================

INSERT INTO lease_info (device_id, provider_name, contract_number, monthly_cost_pln, refresh_date, paying_entity)
SELECT 
    d.id,
    -- Dostawca
    CASE 
        WHEN d.model_name LIKE 'MacBook%' THEN 'Cortland'
        WHEN d.model_name LIKE 'Cisco%' THEN 'Deutsche Telekom'
        WHEN d.model_name LIKE 'Ricoh%' THEN 'Ricoh Polska'
        WHEN d.model_name LIKE 'HP%' THEN 'HP Enterprise'
        ELSE 'Lenovo FS'
    END,
    'L-2024-CORP', -- Numer kontraktu
    -- Koszt
    CASE 
        WHEN d.type = 'Switch' THEN 800.00
        WHEN d.type = 'Router' THEN 1200.00
        WHEN d.model_name LIKE 'MacBook%' THEN 900.00
        WHEN d.model_name LIKE 'Ricoh%' THEN 450.00 -- Duża kserokopiarka
        ELSE 240.00 -- Laptop Lenovo / Mała drukarka
    END,
    '2028-01-01', -- Data wymiany
    -- KTO PŁACI?
    CASE
        WHEN d.type = 'Printer' AND d.is_shared_printer = TRUE THEN 'IT' -- Wspólne płaci IT
        WHEN d.type = 'Printer' AND d.assigned_dep IS NOT NULL THEN (SELECT dep_name FROM departments WHERE dep_id = d.assigned_dep) -- Działowe płaci Dział
        ELSE 'IT' -- Laptopy i Sieć płaci IT
    END
FROM devices d;

-- ==========================================================
-- SOTWARE
-- ==========================================================

-- 1. Catalogue
INSERT INTO software_catalog (soft_name, vendor) VALUES
('Microsoft Office 365', 'Microsoft'), -- ID 1
('SAP S/4HANA', 'SAP'),                -- ID 2
('Adobe Creative Cloud', 'Adobe');     -- ID 3

-- 2. Assigments (Logic)


INSERT INTO employee_software (emp_id, soft_id)
SELECT emp_id, soft_id FROM employees CROSS JOIN software_catalog
WHERE dep_id IN (1, 4, 7); 


INSERT INTO employee_software (emp_id, soft_id)
SELECT emp_id, 1 FROM employees WHERE dep_id IN (2, 3, 5, 6, 9);

INSERT INTO employee_software (emp_id, soft_id)
SELECT emp_id, 2 FROM employees WHERE dep_id IN (2, 3, 5, 6, 9);


INSERT INTO employee_software (emp_id, soft_id) VALUES
((SELECT emp_id FROM employees WHERE dep_id=8 LIMIT 1), 1),
((SELECT emp_id FROM employees WHERE dep_id=8 LIMIT 1), 3), 
((SELECT emp_id FROM employees WHERE dep_id=8 LIMIT 1 OFFSET 1), 1),
((SELECT emp_id FROM employees WHERE dep_id=8 LIMIT 1 OFFSET 1), 3);


INSERT INTO employee_software (emp_id, soft_id)
SELECT emp_id, 1 FROM employees WHERE dep_id IN (10, 11);

-- ==========================================================
-- Additionals
-- ==========================================================

-- Repairs
INSERT INTO repairs (device_id, description, repair_cost)
SELECT id, 'Uszkodzona matryca', 0.00 FROM devices WHERE status = 'Service';

-- View: Finance Raport
CREATE OR REPLACE VIEW v_leasing_report AS
SELECT 
    d.type,
    d.model_name,
    l.paying_entity AS Payer,
    l.monthly_cost_pln
FROM devices d
JOIN lease_info l ON d.id = l.device_id
ORDER BY l.paying_entity;


DELIMITER //
CREATE PROCEDURE OnboardNewEmployee(
    IN p_first_name VARCHAR(50),
    IN p_last_name VARCHAR(50),
    IN p_email VARCHAR(100),
    IN p_position VARCHAR(50),
    IN p_dep_name VARCHAR(50) -- We provide department name instead id
)
BEGIN
    DECLARE v_dep_id INT;
    DECLARE v_new_emp_id INT;
    DECLARE v_laptop_id INT;

    -- 1. find id based on name
    SELECT dep_id INTO v_dep_id FROM departments WHERE dep_name = p_dep_name LIMIT 1;

    IF v_dep_id IS NOT NULL THEN
        -- 2. Add employee
        INSERT INTO employees (first_name, last_name, email, position, dep_id)
        VALUES (p_first_name, p_last_name, p_email, p_position, v_dep_id);
        
        -- Download new employee ID
        SET v_new_emp_id = LAST_INSERT_ID();

        -- 3. Find free laptop
        SELECT id INTO v_laptop_id FROM devices 
        WHERE status = 'In Stock' AND type = 'Laptop' LIMIT 1;

        -- 4. If laptop is free assign 
        IF v_laptop_id IS NOT NULL THEN
            UPDATE devices 
            SET assigned_emp = v_new_emp_id, status = 'In Use' 
            WHERE id = v_laptop_id;
            
            SELECT CONCAT('Sukces: Hired ', p_first_name, ' and laptop was released (ID: ', v_laptop_id, ')') AS Raport;
        ELSE
            SELECT CONCAT('Success: Hired', p_first_name, ', but any laptop is free!') AS Raport;
        END IF;

    ELSE
        SELECT 'Error: Department not found' AS Raport;
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE OffboardEmployee(IN p_email VARCHAR(100))
BEGIN
    DECLARE v_emp_id INT;

    -- 1. Find employee ID
    SELECT emp_id INTO v_emp_id FROM employees WHERE email = p_email;

    IF v_emp_id IS NOT NULL THEN
        -- 2. "Return devices'
        UPDATE devices 
        SET status = 'In Stock', assigned_emp = NULL 
        WHERE assigned_emp = v_emp_id;

        -- 3. Delete employee
        DELETE FROM employees WHERE emp_id = v_emp_id;

        SELECT 'Success: User has been deleted and device returned to stock.' AS Raport;
    ELSE
        SELECT 'Error: User not found' AS Raport;
    END IF;
END //
DELIMITER ;

-- PROCEDURE: Onboarding
DELIMITER //
CREATE PROCEDURE AssignSpareLaptop(IN p_target_email VARCHAR(100))
BEGIN
    DECLARE v_dev_id INT;
    DECLARE v_emp_id INT;
    
    -- Find unassigned lenovo laptop
    SELECT id INTO v_dev_id FROM devices 
    WHERE status = 'In Stock' AND model_name LIKE 'Lenovo%' LIMIT 1;
    
    -- Find employee
    SELECT emp_id INTO v_emp_id FROM employees WHERE email = p_target_email;
    
    IF v_dev_id IS NOT NULL AND v_emp_id IS NOT NULL THEN
        UPDATE devices 
        SET status = 'In Use', assigned_emp = v_emp_id 
        WHERE id = v_dev_id;
        SELECT 'Sukces: Przypisano laptopa z zapasu' AS Msg;
    ELSE
        SELECT 'Błąd: Brak sprzętu lub pracownika' AS Msg;
    END IF;
END //
DELIMITER ;

-- ==========================================================
-- Testing (SELECT)
-- ==========================================================

--  Wheter each employee has software?
SELECT e.last_name, s.soft_name 
FROM employees e 
JOIN employee_software es ON e.emp_id = es.emp_id
JOIN software_catalog s ON es.soft_id = s.soft_id
ORDER BY e.dep_id;

--  who is paying for the printers?
SELECT d.model_name, l.provider_name, l.paying_entity 
FROM devices d JOIN lease_info l ON d.id = l.device_id
WHERE d.type = 'Printer';

-- 3. Inventory status
SELECT type, status, COUNT(*) as Ilosc FROM devices GROUP BY type, status;



-- Looking for apple devices
SELECT * FROM devices WHERE model_name LIKE '%MacBook%';

--   Suppliers which get from us more than 2000
SELECT provider_name, SUM(monthly_cost_pln) as total_faktura
FROM lease_info
GROUP BY provider_name
HAVING total_faktura > 2000;

-- All coast Summary
SELECT 'Naprawa' AS Typ, repair_cost AS Kwota FROM repairs
UNION ALL
SELECT 'Leasing' AS Typ, monthly_cost_pln FROM lease_info;

-- Find deparments which have own printer
SELECT dep_name FROM departments d
WHERE EXISTS (SELECT 1 FROM devices dev WHERE dev.assigned_dep = d.dep_id);

--  Hardware which we have to return in 2027-2028
SELECT d.model_name, l.refresh_date 
FROM devices d JOIN lease_info l ON d.id = l.device_id
WHERE l.refresh_date BETWEEN '2027-01-01' AND '2028-12-31';

-- Show asset assigments to management and IT
SELECT e.last_name, s.soft_name, dep_id
FROM employees e
JOIN employee_software es ON e.emp_id = es.emp_id
JOIN software_catalog s ON es.soft_id = s.soft_id
WHERE e.dep_id IN (1, 2);



-- Check stock status before any action
SELECT COUNT(*) FROM devices WHERE status='In Stock';

-- Check count of employees
SELECT COUNT(*) FROM employees;

-- Hiring new employee
CALL OnboardNewEmployee('Jan', 'Świeżak', 'jan.new@corp.pl', 'Junior Admin', 'IT');

-- Check wheter user returned his device
SELECT e.last_name, d.model_name, d.status 
FROM employees e JOIN devices d ON e.emp_id = d.assigned_emp
WHERE e.email = 'jan.new@corp.pl';

-- check stock status after user added
SELECT COUNT(*) FROM devices WHERE status='In Stock';

-- User has been fired
CALL OffboardEmployee('jan.new@corp.pl');

-- Check wheter the user is still visible in employee list
SELECT * FROM employees WHERE email = 'jan.new@corp.pl';

-- Check whether the laptop has been returned to stock
SELECT COUNT(*) FROM devices WHERE status='In Stock';

