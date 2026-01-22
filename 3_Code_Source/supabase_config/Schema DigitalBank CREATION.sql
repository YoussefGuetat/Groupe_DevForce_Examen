-- ===============================================
-- DigitalBank France - Database Backup
-- Date: 2025-12-08
-- PostgreSQL 14
-- ===============================================

-- Database: digitalbank_restored
-- WARNING: This is a simplified version for educational purposes
-- Full backup file would be 150MB (not included here - use sample data)

-- ===============================================
-- SCHEMA CREATION
-- ===============================================

-- Drop existing tables if any
DROP TABLE IF EXISTS transactions CASCADE;
DROP TABLE IF EXISTS cards CASCADE;
DROP TABLE IF EXISTS accounts CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS login_attempts CASCADE;
DROP TABLE IF EXISTS audit_logs CASCADE;

-- ===============================================
-- TABLE: customers
-- ===============================================

CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    date_of_birth DATE,
    phone VARCHAR(20),
    address TEXT,
    city VARCHAR(100),
    postal_code VARCHAR(10),
    country VARCHAR(50) DEFAULT 'France',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'suspended', 'closed'))
);

-- ===============================================
-- TABLE: accounts
-- ===============================================

CREATE TABLE accounts (
    account_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL,
    account_number VARCHAR(34) UNIQUE NOT NULL, -- IBAN format
    account_type VARCHAR(20) NOT NULL CHECK (account_type IN ('checking', 'savings', 'business')),
    balance DECIMAL(15, 2) DEFAULT 0.00,
    currency VARCHAR(3) DEFAULT 'EUR',
    opened_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'frozen', 'closed')),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
);

-- ===============================================
-- TABLE: cards
-- ===============================================

CREATE TABLE cards (
    card_id SERIAL PRIMARY KEY,
    account_id INT NOT NULL,
    card_number VARCHAR(19) NOT NULL, -- Will be encrypted in practice
    card_type VARCHAR(20) CHECK (card_type IN ('debit', 'credit')),
    expiry_date DATE NOT NULL,
    cvv VARCHAR(3) NOT NULL, -- Will be encrypted in practice
    daily_limit DECIMAL(10, 2) DEFAULT 1000.00,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'blocked', 'expired')),
    issued_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id) ON DELETE CASCADE
);

-- ===============================================
-- TABLE: transactions
-- ===============================================

CREATE TABLE transactions (
    transaction_id SERIAL PRIMARY KEY,
    account_id INT NOT NULL,
    transaction_type VARCHAR(20) CHECK (transaction_type IN ('deposit', 'withdrawal', 'transfer', 'payment', 'fee')),
    amount DECIMAL(15, 2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'EUR',
    merchant_name VARCHAR(255),
    merchant_category VARCHAR(50), -- ex: 'Groceries', 'Electronics', 'Travel', etc.
    location VARCHAR(255), -- ex: 'Paris, France' or 'Online'
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'completed' CHECK (status IN ('pending', 'completed', 'failed', 'reversed')),
    is_fraud BOOLEAN DEFAULT FALSE, -- For ML training purposes
    fraud_score DECIMAL(3, 2), -- Between 0.00 and 1.00
    FOREIGN KEY (account_id) REFERENCES accounts(account_id) ON DELETE CASCADE
);

-- Create index for faster queries on transactions
CREATE INDEX idx_transactions_account_id ON transactions(account_id);
CREATE INDEX idx_transactions_timestamp ON transactions(timestamp);
CREATE INDEX idx_transactions_is_fraud ON transactions(is_fraud);

-- ===============================================
-- TABLE: login_attempts
-- ===============================================

CREATE TABLE login_attempts (
    attempt_id SERIAL PRIMARY KEY,
    email VARCHAR(255),
    ip_address VARCHAR(45) NOT NULL,
    user_agent TEXT,
    success BOOLEAN NOT NULL,
    failure_reason VARCHAR(100), -- ex: 'invalid_password', 'account_locked', etc.
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_login_attempts_ip ON login_attempts(ip_address);
CREATE INDEX idx_login_attempts_timestamp ON login_attempts(timestamp);

-- ===============================================
-- TABLE: audit_logs (for RGPD compliance)
-- ===============================================

CREATE TABLE audit_logs (
    log_id SERIAL PRIMARY KEY,
    user_id INT,
    user_role VARCHAR(50), -- 'admin', 'analyst', 'customer_service', 'customer'
    action VARCHAR(100) NOT NULL, -- ex: 'VIEW_CUSTOMER', 'UPDATE_ACCOUNT', 'DELETE_TRANSACTION'
    table_name VARCHAR(50),
    record_id INT,
    ip_address VARCHAR(45),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===============================================
-- SAMPLE DATA INSERTION
-- ===============================================

-- Insert sample customers (10 examples)
INSERT INTO customers (email, password_hash, first_name, last_name, date_of_birth, phone, address, city, postal_code)
VALUES
('jean.dupont@email.fr', '$2b$12$abcdefghijklmnopqrstuvwxyz12345', 'Jean', 'Dupont', '1985-03-15', '0601020304', '12 Rue de la Paix', 'Paris', '75001'),
('marie.martin@email.fr', '$2b$12$bcdefghijklmnopqrstuvwxyz123456', 'Marie', 'Martin', '1990-07-22', '0612345678', '45 Avenue des Champs', 'Lyon', '69001'),
('pierre.bernard@email.fr', '$2b$12$cdefghijklmnopqrstuvwxyz1234567', 'Pierre', 'Bernard', '1982-11-08', '0623456789', '8 Boulevard Victor Hugo', 'Marseille', '13001'),
('sophie.petit@email.fr', '$2b$12$defghijklmnopqrstuvwxyz12345678', 'Sophie', 'Petit', '1995-02-14', '0634567890', '3 Rue Gambetta', 'Toulouse', '31000'),
('luc.durand@email.fr', '$2b$12$efghijklmnopqrstuvwxyz123456789', 'Luc', 'Durand', '1988-09-30', '0645678901', '15 Allée des Platanes', 'Nice', '06000'),
('claire.moreau@email.fr', '$2b$12$fghijklmnopqrstuvwxyz1234567890', 'Claire', 'Moreau', '1992-05-18', '0656789012', '22 Rue de la République', 'Nantes', '44000'),
('thomas.simon@email.fr', '$2b$12$ghijklmnopqrstuvwxyz12345678901', 'Thomas', 'Simon', '1980-12-25', '0667890123', '9 Place du Marché', 'Strasbourg', '67000'),
('emma.laurent@email.fr', '$2b$12$hijklmnopqrstuvwxyz123456789012', 'Emma', 'Laurent', '1997-08-03', '0678901234', '31 Avenue de la Liberté', 'Bordeaux', '33000'),
('nicolas.lefebvre@email.fr', '$2b$12$ijklmnopqrstuvwxyz1234567890123', 'Nicolas', 'Lefebvre', '1986-04-12', '0689012345', '7 Rue Saint-Michel', 'Lille', '59000'),
('amelie.roux@email.fr', '$2b$12$jklmnopqrstuvwxyz12345678901234', 'Amélie', 'Roux', '1993-10-27', '0690123456', '18 Cours Lafayette', 'Rennes', '35000');

-- Insert sample accounts
INSERT INTO accounts (customer_id, account_number, account_type, balance)
VALUES
(1, 'FR7612345678901234567890123', 'checking', 2500.75),
(1, 'FR7612345678901234567890124', 'savings', 15000.00),
(2, 'FR7612345678901234567890125', 'checking', 3200.50),
(3, 'FR7612345678901234567890126', 'checking', 1800.25),
(3, 'FR7612345678901234567890127', 'business', 45000.00),
(4, 'FR7612345678901234567890128', 'checking', 950.00),
(5, 'FR7612345678901234567890129', 'checking', 5500.80),
(6, 'FR7612345678901234567890130', 'checking', 2100.00),
(6, 'FR7612345678901234567890131', 'savings', 8000.00),
(7, 'FR7612345678901234567890132', 'checking', 3700.50),
(8, 'FR7612345678901234567890133', 'checking', 1200.00),
(9, 'FR7612345678901234567890134', 'checking', 4500.25),
(10, 'FR7612345678901234567890135', 'savings', 12000.00);

-- Insert sample cards
INSERT INTO cards (account_id, card_number, card_type, expiry_date, cvv, daily_limit)
VALUES
(1, '4532123456789012', 'debit', '2027-12-31', '123', 1000.00),
(2, '4532123456789013', 'debit', '2028-06-30', '456', 500.00),
(3, '4532123456789014', 'debit', '2027-09-30', '789', 1500.00),
(4, '5412123456789012', 'credit', '2028-03-31', '234', 3000.00),
(5, '5412123456789013', 'debit', '2027-11-30', '567', 2000.00),
(7, '4532123456789015', 'debit', '2028-01-31', '890', 1000.00),
(9, '4532123456789016', 'debit', '2027-08-31', '345', 1200.00),
(10, '5412123456789014', 'credit', '2028-05-31', '678', 2500.00),
(12, '4532123456789017', 'debit', '2027-10-31', '901', 800.00),
(13, '4532123456789018', 'debit', '2028-02-28', '012', 1500.00);

-- Insert sample transactions (30 examples with some fraudulent)
INSERT INTO transactions (account_id, transaction_type, amount, merchant_name, merchant_category, location, is_fraud)
VALUES
-- Normal transactions
(1, 'payment', -45.50, 'Carrefour Market', 'Groceries', 'Paris, France', FALSE),
(1, 'payment', -120.00, 'SNCF', 'Travel', 'Lyon, France', FALSE),
(1, 'deposit', 1500.00, 'Salary', 'Income', 'Paris, France', FALSE),
(3, 'payment', -89.99, 'Amazon.fr', 'Electronics', 'Online', FALSE),
(3, 'payment', -25.30, 'Starbucks', 'Food & Beverage', 'Paris, France', FALSE),
(5, 'transfer', -500.00, 'Transfer to savings', 'Transfer', 'Online', FALSE),
(5, 'payment', -150.00, 'EDF', 'Utilities', 'Online', FALSE),
(7, 'payment', -200.00, 'Nike Store', 'Clothing', 'Lyon, France', FALSE),
(9, 'payment', -75.50, 'Auchan', 'Groceries', 'Lille, France', FALSE),
(10, 'deposit', 2000.00, 'Salary', 'Income', 'Rennes, France', FALSE),

-- More normal transactions
(1, 'payment', -12.50, 'Boulangerie Paul', 'Food & Beverage', 'Paris, France', FALSE),
(3, 'payment', -350.00, 'FNAC', 'Electronics', 'Paris, France', FALSE),
(4, 'payment', -80.00, 'Shell Station', 'Fuel', 'Marseille, France', FALSE),
(7, 'payment', -450.00, 'Air France', 'Travel', 'Online', FALSE),
(9, 'withdrawal', -100.00, 'ATM Withdrawal', 'Cash', 'Lille, France', FALSE),

-- Fraudulent transactions (unusual patterns)
(1, 'payment', -2500.00, 'Unknown Merchant', 'Electronics', 'Dubai, UAE', TRUE), -- Unusual location + high amount
(3, 'payment', -3500.00, 'Luxury Goods Store', 'Jewelry', 'Hong Kong', TRUE), -- Unusual location
(5, 'payment', -1800.00, 'Casino Royal', 'Gambling', 'Las Vegas, USA', TRUE), -- Unusual category + location
(7, 'payment', -4000.00, 'Cryptocurrency Exchange', 'Finance', 'Online', TRUE), -- High risk category
(1, 'payment', -150.00, 'Unknown Website', 'Online Shopping', 'Unknown', TRUE), -- Suspicious merchant

-- More fraudulent transactions
(3, 'payment', -2200.00, 'Gift Cards Store', 'Retail', 'Online', TRUE), -- High amount on gift cards
(5, 'payment', -1500.00, 'International Wire', 'Transfer', 'Nigeria', TRUE), -- High risk location
(9, 'payment', -800.00, 'Bitcoin ATM', 'Cryptocurrency', 'Paris, France', TRUE), -- High risk category
(10, 'payment', -5000.00, 'Wire Transfer', 'Transfer', 'Russia', TRUE), -- High amount + high risk location
(1, 'payment', -200.00, 'Suspicious Merchant ABC', 'Unknown', 'Online', TRUE),

-- Additional normal transactions for variety
(4, 'payment', -35.00, 'McDonalds', 'Food & Beverage', 'Marseille, France', FALSE),
(7, 'payment', -60.00, 'Pharmacie', 'Health', 'Strasbourg, France', FALSE),
(10, 'payment', -180.00, 'H&M', 'Clothing', 'Rennes, France', FALSE),
(12, 'payment', -95.00, 'Cinema Gaumont', 'Entertainment', 'Bordeaux, France', FALSE),
(13, 'payment', -250.00, 'Hotel Ibis', 'Travel', 'Nice, France', FALSE);

-- Insert sample login attempts (mix of successful and failed)
INSERT INTO login_attempts (email, ip_address, user_agent, success, failure_reason)
VALUES
('jean.dupont@email.fr', '192.168.1.100', 'Mozilla/5.0 (Windows NT 10.0)', TRUE, NULL),
('marie.martin@email.fr', '192.168.1.101', 'Mozilla/5.0 (Macintosh)', TRUE, NULL),
('invalid@email.fr', '45.123.45.67', 'curl/7.68.0', FALSE, 'invalid_email'), -- Suspicious
('jean.dupont@email.fr', '45.123.45.67', 'Python-requests', FALSE, 'invalid_password'), -- Suspicious IP
('jean.dupont@email.fr', '45.123.45.67', 'Python-requests', FALSE, 'invalid_password'), -- Multiple attempts
('jean.dupont@email.fr', '45.123.45.67', 'Python-requests', FALSE, 'invalid_password'), -- Multiple attempts
('pierre.bernard@email.fr', '192.168.1.102', 'Mozilla/5.0 (iPhone)', TRUE, NULL),
('admin@digitalbank.fr', '89.234.56.78', 'curl/7.68.0', FALSE, 'invalid_email'), -- Attempted admin login
('admin@digitalbank.fr', '89.234.56.78', 'curl/7.68.0', FALSE, 'invalid_email'), -- Suspicious
('sophie.petit@email.fr', '192.168.1.103', 'Mozilla/5.0 (Android)', TRUE, NULL);

-- ===============================================
-- NOTES FOR STUDENTS
-- ===============================================

-- 1. This is a SIMPLIFIED version of the database. 
--    In reality, DigitalBank would have 850,000 customers and 95 million transactions.
--
-- 2. For your exercises, you can:
--    - Use this as a base and generate more fake data with Python (Faker library)
--    - Or work with this sample data for demonstration purposes
--
-- 3. Security notes:
--    - Passwords are hashed with bcrypt (example hashes shown)
--    - Card numbers and CVVs should be encrypted with pgcrypto (exercise for you!)
--    - Implement Row Level Security (RLS) to restrict access
--
-- 4. To restore this database:
--    sudo -u postgres psql
--    CREATE DATABASE digitalbank_restored;
--    \c digitalbank_restored
--    \i digitalbank_backup_20251208.sql
--
-- 5. Verification queries (as mentioned in the exam):
--    SELECT COUNT(*) FROM customers; -- Should return 10
--    SELECT COUNT(*) FROM accounts; -- Should return 13
--    SELECT COUNT(*) FROM transactions; -- Should return 30
--    SELECT COUNT(*) FROM transactions WHERE is_fraud = TRUE; -- Should return 10

-- ===============================================
-- END OF BACKUP FILE
-- ===============================================