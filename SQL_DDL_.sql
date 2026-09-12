CREATE DATABASE auction_house;

-- Create schema if not exists
CREATE SCHEMA IF NOT EXISTS auction_house_data;

-- Create users table
CREATE TABLE auction_house_data.users (
    user_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(50) NOT NULL,
    email VARCHAR(50) NOT NULL UNIQUE,-- email should be unique
    additional_info VARCHAR(150) NOT NULL
);

ALTER TABLE auction_house_data.users
ADD COLUMN record_ts DATE NOT NULL DEFAULT CURRENT_DATE;--- altered a new table as in the instruction

-- Create roles table
CREATE TABLE auction_house_data.role (
    id SERIAL PRIMARY KEY,
    title VARCHAR(50) NOT NULL
);
ALTER TABLE auction_house_data.role
ADD COLUMN record_ts DATE NOT NULL DEFAULT CURRENT_DATE;

-- Insert roles
INSERT INTO auction_house_data.role (title)
VALUES 
    ('both seller and buyer'), 
    ('seller');

-- Create user_role table
CREATE TABLE auction_house_data.user_role (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES auction_house_data.users(user_id),
    role_id INT NOT NULL REFERENCES auction_house_data.role(id),
    record_ts DATE NOT NULL DEFAULT CURRENT_DATE
);


-- Create product_categories table (This should be created before inserting or referencing it)
CREATE TABLE auction_house_data.product_categories (
    id SERIAL PRIMARY KEY,
    title VARCHAR(50) NOT NULL,
    parent_id INT REFERENCES auction_house_data.product_categories(id),
    record_ts DATE NOT NULL DEFAULT CURRENT_DATE
);

-- Insert categories into product_categories
INSERT INTO auction_house_data.product_categories (title, parent_id) 
VALUES 
    ('dishes', NULL),
    ('clothes', NULL);

-- Create products table 
CREATE TABLE auction_house_data.product (
    id SERIAL PRIMARY KEY,
    title VARCHAR(50) NOT NULL,
    price DOUBLE PRECISION NOT NULL CHECK (price >= 0),  -- Non-negative price
    category_id INT NOT NULL REFERENCES auction_house_data.product_categories(id),
    additional_info VARCHAR(150),
    record_ts DATE NOT NULL DEFAULT CURRENT_DATE
);

-- Insert users
INSERT INTO auction_house_data.users (name, phone_number, email, additional_info)
VALUES 
    ('Takhmina Zhumakova', '+996505111501', 'takhminazhumakova@gmail.com', 'From Kyrgyzstan, prefers antique plates'),
    ('Aidai Shaaeva', '+996704906030', 'aidaishaa69@gmail.com', 'From Kyrgyzstan, prefers traditional songs');

-- Insert user roles
INSERT INTO auction_house_data.user_role (user_id, role_id) 
VALUES 
    (1, 1),  -- Takhmina Zhumakova: both seller and buyer
    (3, 2);  -- Aidai Shaaeva: seller
    
CREATE TABLE auction_house_data.product (
    id SERIAL PRIMARY KEY,
    title VARCHAR(50) NOT NULL,
    price DOUBLE PRECISION NOT NULL CHECK (price >= 0), -- Non-negative price
    category_id INT NOT NULL REFERENCES product_categories(id),
    additional_info VARCHAR(150),
    record_ts DATE NOT NULL DEFAULT CURRENT_DATE
);

INSERT into auction_house_data.product (title, price, category_id, additional_info) VALUES
('chinese plate', 99.99, 1, 'glass'),
('italian dress', 666.50, 2, 'chiffon');

select * from auction_house_data.product

CREATE TABLE auction_house_data.client_addresses (
    id SERIAL PRIMARY KEY,
    title VARCHAR(50) NOT NULL,
    address VARCHAR(500) NOT NULL,
    isActive BOOLEAN DEFAULT TRUE,-- to check the condition
    clientId INT NOT NULL REFERENCES auction_house_data.users(user_id),
    record_ts DATE NOT NULL DEFAULT CURRENT_DATE
);

INSERT INTO auction_house_data.client_addresses (title, address, clientId) VALUES
('Home', '123 Tokyo Ave', 1),
('Office', '456 Sushi Blvd', 3);
select * from auction_house_data.client_addresses

CREATE TABLE auction_house_data.orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES auction_house_data.users(user_id),
    order_date DATE NOT NULL CHECK (order_date > '2000-01-01'), -- CHECK 1: greater than 2020 january 1
    record_ts DATE NOT NULL DEFAULT CURRENT_DATE
);

INSERT INTO auction_house_data.orders (customer_id, order_date) VALUES
(1, '2024-04-01'),
(3, '2024-04-02');

CREATE TABLE auction_house_data.order_items (
    id SERIAL PRIMARY KEY,
    order_id INT NOT NULL REFERENCES auction_house_data.orders(order_id),
    product_id INT NOT NULL REFERENCES auction_house_data.product(id),
    record_ts DATE NOT NULL DEFAULT CURRENT_DATE
);


-- SHIPMENTS TABLE

CREATE TABLE auction_house_data.shipments (
    shipment_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL REFERENCES auction_house_data.orders(order_id),
    shipment_date DATE NOT NULL CHECK (shipment_date > '2000-01-01'), -- CHECK 2
    delivery_user_id INT NOT NULL REFERENCES auction_house_data.users(user_id),
    client_address_id INT NOT NULL REFERENCES auction_house_data.client_addresses(id),
    record_ts DATE NOT NULL DEFAULT CURRENT_DATE
);
INSERT INTO auction_house_data.order_items (order_id, product_id) VALUES
(1, 1),
(2, 2);

-- Insert shipments
INSERT INTO auction_house_data.shipments (order_id, shipment_date, delivery_user_id, client_address_id) VALUES
(1, '2024-04-03', 1, 3),
(2, '2024-04-04', 3, 4);

