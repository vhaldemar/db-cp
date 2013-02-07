#!/usr/bin/perl -w
package Config;
use strict;

# CONFIG SECTIO

BEGIN {
	our @paramList = qw(
		siteName
		root
		dbHost
		dbName
		dbUser
		dbPass
		dbPort
	);

	our $siteName = 'dbcp';
	our $root = '/home/lipkin/git/db-cp/htdocs';
	our $passSalt = '';

	our $dbHost = 'localhost';
	our $dbName = 'dbcp';
	our $dbUser = 'postgres';
	our $dbPass = 'mrkimok';
	our $dbPort = '5432';
}

#END OF CONFIG SECTION

1;
