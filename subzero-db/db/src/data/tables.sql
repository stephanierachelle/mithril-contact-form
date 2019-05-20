create table client_contact (
  id           serial primary key,
  firstName    text not null,
  lastName     text not null,
  email        text not null,
  messageInput text not null,
  user_id      int not null references "user"(id),
  created_on   timestamptz not null default now(),
  updated_on   timestamptz,
);
create index client_contact_user_id_index on client_contact(user_id);