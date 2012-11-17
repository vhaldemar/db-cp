#!/usr/bin/perl -w
use strict;
use DBI;
use Shared;
use utf8;

my $usersQuery = qq(
	create table if not exists Users (
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
);

print header(-charset => 'utf-8');
print start_html(
	-lang => 'ru-RU',
	-title => 'Index',
);

print p("install.pl");
print p("Connection to database...");
my $dbh = Shared::ConnectDB();
print p("Connection succes! ");

my $sth = $dbh->prepare($usersQuery);
$sth->execute();

if ($DBI::errstr) {
	print $DBI::errstr;
} else {
	print p('Please, delete install.pl from your site folder');
}
print end_html();

1;
