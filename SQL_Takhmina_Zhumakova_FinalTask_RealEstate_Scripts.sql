
CREATE database if not EXISTS real_estate_agency;

CREATE schema if not EXISTS agency_data;

SET search_path TO agency_data;


CREATE TABLE client (
    client_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    phone TEXT,
    email TEXT,
    client_type TEXT CHECK (client_type IN ('Buyer', 'Seller', 'Tenant', 'Landlord'))
);


CREATE TABLE agent (
    agent_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT,
    hire_date DATE
);


CREATE TABLE agentclient (
    agent_id INT REFERENCES agent(agent_id) ON DELETE CASCADE,
    client_id INT REFERENCES client(client_id) ON DELETE CASCADE,
    PRIMARY KEY (agent_id, client_id)
);


CREATE TABLE properties (
    property_id SERIAL PRIMARY KEY,
    address TEXT NOT NULL,
    type TEXT, -- Could be normalized further
    status TEXT CHECK (status IN ('Available', 'Sold', 'Rented')),
    price NUMERIC(12,2),
    owner_id INT REFERENCES client(client_id)
);

CREATE TABLE transactions (
    transaction_id SERIAL PRIMARY KEY,
    property_id INT REFERENCES properties(property_id) ON DELETE SET NULL,
    agent_id INT REFERENCES agent(agent_id) ON DELETE SET NULL,
    buyer_id INT REFERENCES client(client_id),
    seller_id INT REFERENCES client(client_id),
    transaction_date DATE,
    price_sold NUMERIC(12,2),
    CHECK (buyer_id <> seller_id)
);


CREATE TABLE financerecord (
    financerecord_id SERIAL PRIMARY KEY,
    transaction_id INT REFERENCES transactions(transaction_id) ON DELETE CASCADE,
    agent_id INT REFERENCES agent(agent_id),
    agency_fee NUMERIC(12,2),
    expense NUMERIC(12,2),
    commission NUMERIC(12,2)
);


CREATE TABLE market_data (
    market_id SERIAL PRIMARY KEY,
    property_id INT REFERENCES properties(property_id) ON DELETE CASCADE,
    date_recorded DATE,
    estimated_value NUMERIC(12,2),
    neighborhood TEXT
);


ALTER TABLE agency_data.transactions
ADD CONSTRAINT chk_transaction_date_future
CHECK (transaction_date > DATE '2024-01-01');


ALTER TABLE agency_data.market_data
ADD CONSTRAINT chk_estimated_value_positive
CHECK (estimated_value >= 0);


ALTER TABLE agency_data.client
ADD CONSTRAINT chk_client_type_valid
CHECK (client_type IN ('Buyer', 'Seller', 'Tenant', 'Landlord'));


ALTER TABLE agency_data.agent
ADD CONSTRAINT uq_agent_email UNIQUE (email);


ALTER TABLE agency_data.financerecord
ALTER COLUMN commission SET NOT NULL;

ALTER TABLE agency_data.financerecord
ADD CONSTRAINT chk_commission_non_negative
CHECK (commission >= 0);


ALTER TABLE agency_data.properties
ALTER COLUMN status SET DEFAULT 'Available';


ALTER TABLE agency_data.financerecord
ADD COLUMN total_income NUMERIC(12,2) 
GENERATED ALWAYS AS (agency_fee + commission) STORED;

INSERT INTO agency_data.client (name, phone, email, client_type) VALUES
('Alice Smith', '555-1234', 'alice@example.com', 'Buyer'),
('Bob Johnson', '555-2345', 'bob@example.com', 'Seller'),
('Carol White', '555-3456', 'carol@example.com', 'Tenant'),
('David Lee', '555-4567', 'david@example.com', 'Landlord'),
('Eva Green', '555-5678', 'eva@example.com', 'Buyer'),
('Frank Stone', '555-6789', 'frank@example.com', 'Seller');

INSERT INTO agency_data.agent (name, email, hire_date) VALUES
('Agent One', 'agent1@agency.com', '2022-05-01'),
('Agent Two', 'agent2@agency.com', '2023-01-15'),
('Agent Three', 'agent3@agency.com', '2024-03-10'),
('Agent Four', 'agent4@agency.com', '2021-09-25'),
('Agent Five', 'agent5@agency.com', '2023-11-07'),
('Agent Six', 'agent6@agency.com', '2022-06-30');

INSERT INTO agency_data.agentclient (agent_id, client_id) VALUES
(1, 1), (1, 2), (2, 3),
(2, 4), (3, 5), (3, 6);

INSERT INTO agency_data.properties (address, type, price, owner_id) VALUES
('123 Elm St', 'House', 250000.00, 2),
('456 Oak Ave', 'Apartment', 180000.00, 6),
('789 Pine Rd', 'Condo', 300000.00, 4),
('101 Maple Ln', 'Townhouse', 220000.00, 2),
('202 Birch Blvd', 'House', 275000.00, 6),
('303 Cedar Ct', 'Apartment', 200000.00, 4);

INSERT INTO agency_data.transactions (property_id, agent_id, buyer_id, seller_id, transaction_date, price_sold) VALUES
(1, 1, 1, 2, '2025-03-15', 248000.00),
(2, 2, 5, 6, '2025-04-10', 182000.00),
(3, 3, 1, 4, '2025-05-01', 299000.00),
(4, 1, 5, 2, '2025-05-05', 219500.00),
(5, 2, 1, 6, '2025-03-20', 273000.00),
(6, 3, 5, 4, '2025-04-25', 198000.00);

INSERT INTO agency_data.financerecord (transaction_id, agent_id, agency_fee, expense, commission) VALUES
(1, 1, 7000.00, 1000.00, 3000.00),
(2, 2, 6500.00, 800.00, 2500.00),
(3, 3, 7500.00, 950.00, 3200.00),
(4, 1, 7100.00, 870.00, 3100.00),
(5, 2, 7300.00, 920.00, 3300.00),
(6, 3, 6800.00, 860.00, 2800.00);

INSERT INTO agency_data.market_data (property_id, date_recorded, estimated_value, neighborhood) VALUES
(1, '2025-03-10', 249000.00, 'Downtown'),
(2, '2025-04-05', 181000.00, 'Midtown'),
(3, '2025-04-30', 298500.00, 'Uptown'),
(4, '2025-05-02', 220000.00, 'Suburbs'),
(5, '2025-03-18', 274000.00, 'Downtown'),
(6, '2025-04-20', 199000.00, 'Midtown');

UPDATE agency_data.client
SET phone = '555-9999'
WHERE client_id = 1;

UPDATE agency_data.client
SET email = 'newemail@example.com'
WHERE client_id = 2;

CREATE OR REPLACE FUNCTION agency_data.add_transaction(
    p_property_id INT,
    p_agent_id INT,
    p_buyer_id INT,
    p_seller_id INT,
    p_transaction_date DATE,
    p_price_sold NUMERIC(12,2)
) 
RETURNS void AS $$
BEGIN
    INSERT INTO agency_data.transactions (
        property_id, 
        agent_id, 
        buyer_id, 
        seller_id, 
        transaction_date, 
        price_sold
    ) 
    VALUES (
        p_property_id, 
        p_agent_id, 
        p_buyer_id, 
        p_seller_id, 
        p_transaction_date, 
        p_price_sold
    );
END;
$$ LANGUAGE plpgsql;

CREATE VIEW agency_data.simple_quarterly_analytics AS
SELECT 
    COUNT(*) AS total_transactions,
    SUM(t.price_sold) AS total_sales_value
FROM 
    agency_data.transactions t
WHERE 
    t.transaction_date >= CURRENT_DATE - INTERVAL '3 months';

SELECT * FROM agency_data.simple_quarterly_analytics;


CREATE role if not EXISTS manager_readonly LOGIN PASSWORD 'your_secure_password';


GRANT SELECT ON ALL TABLES IN SCHEMA agency_data TO manager_readonly;


GRANT CONNECT ON DATABASE real_estate_agency TO manager_readonly;







