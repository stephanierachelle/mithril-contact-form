-- Revert app:0000000002-data from pg

BEGIN;

DROP TABLE Contact_Form_Queries;

COMMIT;