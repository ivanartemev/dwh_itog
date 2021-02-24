create database bookings_dwh;

create schema bookings;

create table Dim_Calendar 
as
with dates as (
	select dd::date as dt
	from generate_series 
		('2010-01-01' :: timestamp,
		'2030-01-01' :: timestamp,
		'1 day' :: interval) dd
		)
select
	to_char (dt, 'YYYYMMDD'):: int as id,
	dt as date,
	to_char (dt, 'YYYY-MM-DD') as ansi_date,
	date_part ('isodow', dt) :: int as day,
	date_part ('week', dt) :: int as week_number,
	date_part ('month', dt) :: int as month,
	date_part ('isoyear', dt) :: int as year
from dates 
order by dt;

alter table Dim_Calendar add primary key (id);



create table Dim_Passengers(
passenger_id varchar (20) not null,
passenger_name text not null,
phone text,
email text,
check (phone is not null or email is not null),
primary key (passenger_id)
);





create table Dim_Aircrafts(
aircraft_code char (3) not null,
model_ru text not null,
model_en text not null,
"range" int not null,
check ("range" > 0),
primary key (aircraft_code)
);



create table Dim_Airports(
airport_code char (3) not null,
airport_name_ru text not null,
airport_name_en text not null,
city_ru text not null,
city_en text not null,
coordinates text not null,
timezone text not null,
primary key (airport_code)
);




create table Dim_Tariff(
flight_id int not null,
fare_conditions_amount text not null,
primary key (flight_id) 
);



create table Fact_Flights(
id serial8 not null,
date_key int not null references Dim_Calendar (id),
flight_id int not null references Dim_Tariff (flight_id),
passenger_key varchar (20) not null references Dim_Passengers (passenger_id),
scheduled_departure timestamptz not null,
scheduled_arrival timestamptz not null,
actual_departure_sec int,
actual_arrival_sec int,
aircraft_key char (3) not null references Dim_Aircrafts (aircraft_code),
departure_airport_key char (3) not null references Dim_Airports (airport_code),
arrival_airport_key char (3) not null references Dim_Airports (airport_code),
fare_conditions varchar (10) not null,
amount numeric (10,2) not null,
CHECK (scheduled_arrival > scheduled_departure),
CHECK ( fare_conditions = 'Economy' or fare_conditions = 'Comfort' or fare_conditions = 'Business' ),
CHECK ( amount >= 0 ),
primary key (id)
);




