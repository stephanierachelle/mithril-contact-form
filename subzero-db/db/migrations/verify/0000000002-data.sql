-- Verify app:0000000002-data on pg

BEGIN;

SELECT PersonID, FirstName, LastName, Email, MessageInput, Timestamp
FROM app:0000000002-data
WHERE FALSE;

ROLLBACK;