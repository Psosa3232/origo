-- =========================================================
-- ORIGO — PostgreSQL Relational Schema
-- Structured data: customers, contracts, billing
-- =========================================================

-- Master table: core customer data
CREATE TABLE customers (
    customer_id     SERIAL PRIMARY KEY,
    first_name      VARCHAR(100) NOT NULL,
    last_name       VARCHAR(100) NOT NULL,
    email           VARCHAR(255) NOT NULL UNIQUE,
    phone           VARCHAR(50),
    country         VARCHAR(100),
    signup_date     DATE NOT NULL
);

-- Catalog table: available service plans (referenced by contracts)
CREATE TABLE plans (
    plan_id         SERIAL PRIMARY KEY,
    plan_name       VARCHAR(100) NOT NULL,
    plan_type       VARCHAR(50) NOT NULL,
    base_price      DECIMAL(10, 2) NOT NULL,
    billing_cycle   VARCHAR(50) NOT NULL
);

-- Links a customer to a plan over a time period
CREATE TABLE contracts (
    contract_id     SERIAL PRIMARY KEY,
    start_date      DATE NOT NULL,
    end_date        DATE,               -- NULL = still active
    status          VARCHAR(50) NOT NULL,
    customer_id     INT NOT NULL,
    plan_id         INT NOT NULL,

    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (plan_id) REFERENCES plans(plan_id)
);

-- Payment methods a customer has on file
CREATE TABLE payment_methods (
    payment_method_id   SERIAL PRIMARY KEY,
    method_type         VARCHAR(50) NOT NULL,
    is_default          BOOLEAN DEFAULT FALSE,
    customer_id         INT NOT NULL,

    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Billing history tied to a contract and payment method
CREATE TABLE invoices (
    invoice_id          SERIAL PRIMARY KEY,
    issue_date           DATE NOT NULL,
    amount               DECIMAL(10, 2) NOT NULL,
    status                VARCHAR(50) NOT NULL,
    payment_method_id    INT,           -- nullable: invoice may be pending payment
    contract_id           INT NOT NULL,

    FOREIGN KEY (payment_method_id) REFERENCES payment_methods(payment_method_id),
    FOREIGN KEY (contract_id) REFERENCES contracts(contract_id)
);

-- Event log for customer behavior (feeds churn features later)
CREATE TABLE customer_events (
    customer_event_id   SERIAL PRIMARY KEY,
    event_type           VARCHAR(100) NOT NULL,  -- e.g. plan_change, complaint, cancellation_request
    event_date            TIMESTAMP NOT NULL,
    notes                  TEXT,
    customer_id            INT NOT NULL,

    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);