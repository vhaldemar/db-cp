#!/usr/bin/perl -w
package Config;
use strict;

# CONFIG SECTION

BEGIN {
	our $siteName = 'dbcp';
	our $root = '/home/vhaldemar/git/db-cp/htdocs';
	our $dbHost = 'localhost';
	our $dbName = 'dbcp';
	our $dbUser = 'postgres';
	our $dbPass = 'mrkimok';
	our $dbPort = '5432';
}

#END OF CONFIG SECTION

1;
