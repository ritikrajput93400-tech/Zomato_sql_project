-- zomato data analysis using sql 
drop table if exists customer;
drop table if exists restaurants;
drop table if exists orders;
drop table if exists riders;
drop table if exists deliveries;

create table customer
(

	customer_id int primary key ,
	customer_name varchar (25),
	reg_date date 
);



create table restaurants
(
	restaurant_id int primary key  ,
	restaurant_name varchar(55),
	city varchar(15),
	opening_hours varchar(55)


);

create table orders
(
	order_id int primary key ,
	customer_id int ,-- this is coming from customemr table 
	restaurant_id int ,-- this is coming from restaurant table 
	order_item varchar(55),
	order_date date ,
	order_time  time ,
	order_status varchar(55),
	total_amount float

);
--  add constraints 
alter table orders
add constraint fk_customers
foreign key (customer_id)
references customer(customer_id);

alter table orders
add constraint fk_restaurant
foreign key (restaurant_id)
references restaurants(restaurant_id);



create table riders
(
	rider_id int primary key,
	rider_name varchar(55),
	sign_up date 

);


create table deliveries
(
delivery_id int primary key   ,
order_id int ,-- this coming from orders table 
delivery_status varchar(35),
delivery_time time ,
rider_id int,-- this is coming from riders table 
constraint fk_orders foreign key (order_id) references orders(order_id),
constraint fk_riders foreign key (rider_id) references riders(rider_id)
);

drop table if exists deliveries;

alter table deliveries
add constraint fk_orders
foreign key (restaurant_id)
references restaurants(restaurant_id);

--  end of schemas 






