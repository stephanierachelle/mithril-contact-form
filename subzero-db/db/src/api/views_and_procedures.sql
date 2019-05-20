create or replace view clients_contact as
select id, firstName, lastName, email, messageInput, created_on, updated_on from data.client_contact;