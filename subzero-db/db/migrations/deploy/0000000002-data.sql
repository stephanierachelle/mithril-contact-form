-- Deploy app:0000000002-data to pg

BEGIN;

CREATE TABLE Contact_Form_Queries (
    PersonID INT,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Email VARCHAR(50),
    MessageInput VARCHAR(500),
    Timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW()
)

COMMIT;