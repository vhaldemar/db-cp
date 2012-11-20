Create table if not exists Users (
	id serial primary key,
	login varchar(255) not null unique,
	password char(16) not null,
	email varchar(255) not null,
	city varchar(255),
	name varchar(255),
	phone char(20),
	adress varchar(255)
);

create index on Users (login);
