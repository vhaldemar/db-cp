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
	our $root = '/home/vhaldemar/git/db-cp/htdocs';
	our $sessions = '/home/vhaldemar/git/db-cp/sessions';
	our $passSalt = '';

	our $dbHost = 'localhost';
	our $dbName = 'dbcp';
	our $dbUser = 'postgres';
	our $dbPass = 'mrkimok';
	our $dbPort = '5432';
	
	our $currency = 'руб.';
	our $minPrice = 100;
	our $minStep = 1;

	our $auctionsOnPage = 15;
	our $eventsPerPage = 15;

	our %defPageParams = (
		css => {
			'base.css' => 1,
		},
		javascript => {
		},
	);

}

#END OF CONFIG SECTION

1;
