-- Deploy app:0000000002-data to pg

BEGIN;

SET search_path = settings, pg_catalog, public;

COPY secrets (key, value) FROM stdin;
jwt_lifetime    3600
auth.default-role   webuser
auth.data-schema    data
auth.api-schema api
\.

INSERT INTO secrets (key, value) VALUES ('jwt_secret', gen_random_uuid());

COMMIT;