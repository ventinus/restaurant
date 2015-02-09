
create table foods (
id serial primary key,
name text,
category text,
price int,
created_at timestamp,
updated_at timestamp);

create table orders (
id serial primary key,
party_id int,
food_id int,
created_at timestamp,
updated_at timestamp);

create table parties (
id serial primary key,
guests int,
paid boolean default false,
table_number int,
created_at timestamp,
updated_at timestamp);

create table receipts (
id serial primary key,
party_id int,
sub_total int,
gratuity int,
total int,
created_at timestamp,
updated_at timestamp);

create table employees (
id serial primary key,
username text,
created_at timestamp,
updated_at timestamp);
CREATE TABLE
