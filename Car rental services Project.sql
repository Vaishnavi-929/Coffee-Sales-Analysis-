-- CAR RENTAL SERVICE PROJECT

CREATE DATABASE CarRentalService;

USE CarRentalService;

-- CREATE TABLES

-- Vehicle Types Table
CREATE TABLE vehicle_types (
    type_id INT PRIMARY KEY AUTO_INCREMENT,
    type_name VARCHAR(50),
    rental_category VARCHAR(50)
);

-- Vehicles Table
CREATE TABLE vehicles (
    vehicle_id INT PRIMARY KEY AUTO_INCREMENT,
    license_plate VARCHAR(20) UNIQUE,
    make VARCHAR(50),
    model VARCHAR(50),
    year INT,
    color VARCHAR(30),
    daily_rate DECIMAL(10,2),
    status VARCHAR(20),
    type_id INT,
    FOREIGN KEY (type_id) REFERENCES vehicle_types(type_id)
);

-- Customers Table
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    driver_license_number VARCHAR(50) UNIQUE,
    phone VARCHAR(15)
);

-- Rentals Table
CREATE TABLE rentals (
    rental_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    vehicle_id INT,
    rental_date DATE,
    return_date DATE,
    total_cost DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id)
);

-- Payments Table
CREATE TABLE payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    rental_id INT,
    payment_date DATE,
    amount DECIMAL(10,2),
    FOREIGN KEY (rental_id) REFERENCES rentals(rental_id)
);

-- INSERT VALUES

-- Vehicle Types
INSERT INTO vehicle_types(type_name, rental_category)
VALUES
('SUV','Luxury'),
('Sedan','Standard'),
('Hatchback','Economy'),
('Truck','Commercial'),
('Convertible','Premium');

-- Vehicles
INSERT INTO vehicles
(license_plate, make, model, year, color, daily_rate, status, type_id)
VALUES
('MH01AB1234','Toyota','Fortuner',2022,'Black',5000,'Available',1),
('MH02CD5678','Honda','City',2021,'White',3000,'Rented',2),
('MH03EF9012','Hyundai','i20',2020,'Red',2000,'Available',3),
('MH04GH3456','Tata','Ace',2019,'Blue',2500,'Maintenance',4),
('MH05IJ7890','BMW','Z4',2023,'Yellow',8000,'Rented',5);

-- Customers
INSERT INTO customers
(name, driver_license_number, phone)
VALUES
('Amit Sharma','DL12345','9876543210'),
('Priya Verma','DL67890','9876501234'),
('Rahul Patil','DL54321','9988776655'),
('Sneha Joshi','DL98765','9123456780'),
('Karan Mehta','DL11223','9000011111');

-- Rentals
INSERT INTO rentals
(customer_id, vehicle_id, rental_date, return_date, total_cost)
VALUES
(1,2,'2026-05-01','2026-05-05',12000),
(2,5,'2026-05-03',NULL,16000),
(3,1,'2026-05-02','2026-05-06',20000),
(1,3,'2026-05-04','2026-05-07',6000),
(4,2,'2026-05-06',NULL,9000),
(5,1,'2026-05-07','2026-05-10',15000);

-- Payments
INSERT INTO payments
(rental_id, payment_date, amount)
VALUES
(1,'2026-05-05',12000),
(2,'2026-05-08',16000),
(3,'2026-05-06',20000),
(4,'2026-05-07',6000),
(5,'2026-05-09',9000),
(6,'2026-05-10',15000);

SELECT*FROM vehicle_types;
SELECT*FROM vehicles;
SELECT*FROM customers;
SELECT*FROM rentals;
SELECT*FROM payments;

-- QUERIES

-- 1. List all vehicles currently rented out
SELECT v.vehicle_id, v.make, v.model, v.status
FROM vehicles v
JOIN rentals r
ON v.vehicle_id = r.vehicle_id
WHERE r.return_date IS NULL;

-- 2. Total revenue generated per vehicle model
SELECT v.model,
SUM(r.total_cost) AS total_revenue
FROM vehicles v
JOIN rentals r
ON v.vehicle_id = r.vehicle_id
GROUP BY v.model;

-- 3. Most frequently rented vehicle type
SELECT vt.type_name,
COUNT(r.rental_id) AS rental_count
FROM vehicle_types vt
JOIN vehicles v
ON vt.type_id = v.type_id
JOIN rentals r
ON v.vehicle_id = r.vehicle_id
GROUP BY vt.type_name
ORDER BY rental_count DESC
LIMIT 1;

-- 4. Customers with overdue rentals
SELECT c.customer_id, c.name, r.return_date
FROM customers c
JOIN rentals r
ON c.customer_id = r.customer_id
WHERE r.return_date < CURDATE();

-- 5. Average rental duration per vehicle type
SELECT vt.type_name,
AVG(DATEDIFF(r.return_date, r.rental_date)) AS avg_days
FROM vehicle_types vt
JOIN vehicles v
ON vt.type_id = v.type_id
JOIN rentals r
ON v.vehicle_id = r.vehicle_id
WHERE r.return_date IS NOT NULL
GROUP BY vt.type_name;

-- 6. Vehicle rented the most number of times
SELECT v.vehicle_id, v.make, v.model,
COUNT(r.rental_id) AS total_rentals
FROM vehicles v
JOIN rentals r
ON v.vehicle_id = r.vehicle_id
GROUP BY v.vehicle_id, v.make, v.model
ORDER BY total_rentals DESC
LIMIT 1;

-- 7. Rentals with additional charges
SELECT rental_id, total_cost
FROM rentals
WHERE total_cost > 15000;

-- 8. Customers who rented more than 5 times
SELECT c.customer_id, c.name,
COUNT(r.rental_id) AS rental_count
FROM customers c
JOIN rentals r
ON c.customer_id = r.customer_id
GROUP BY c.customer_id, c.name
HAVING COUNT(r.rental_id) > 1;

-- 9. Utilization rate for each vehicle
SELECT v.vehicle_id, v.make, v.model,
SUM(DATEDIFF(
IFNULL(r.return_date, CURDATE()),
r.rental_date
)) AS total_rented_days
FROM vehicles v
JOIN rentals r
ON v.vehicle_id = r.vehicle_id
GROUP BY v.vehicle_id, v.make, v.model;

-- 10. Most profitable customer
SELECT c.customer_id, c.name,
SUM(p.amount) AS total_payment
FROM customers c
JOIN rentals r
ON c.customer_id = r.customer_id
JOIN payments p
ON r.rental_id = p.rental_id
GROUP BY c.customer_id, c.name
ORDER BY total_payment DESC
LIMIT 1;


