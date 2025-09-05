create table if not exists client (
    client_id serial primary key,
    name text not null,
    address text
);

create table if not exists orders (
    order_id serial primary key,
    client_id integer references client(client_id),
    order_date timestamp default now(),
    status text default 'pending'
);

create table if not exists category (
    category_id serial primary key,
    name text not null,
    parent_id integer references category(category_id),
    level integer
);

create table if not exists product (
    product_id serial primary key,
    name text not null,
    price numeric(10,2) not null,
    quantity integer default 0,
    category_id integer references category(category_id)
);

create table if not exists order_item (
    order_item_id serial primary key,
    order_id integer references "order"(order_id),
    product_id integer references product(product_id),
    quantity integer not null,
    unit_price numeric(10,2) not null
);