package Shared;
use strict;
use warnings;
use DBI;
use config;

sub ConnectDB
{
	my $dbh = DBI->connect(
			"dbi:Pg:database=$Config::dbName;host=$Config::dbHost;port=$Config::dbPort",
			$Config::dbUser,
			$Config::dbPass,
			{
				PrintError => 0,
				RaiseError => 0,
			}
		) or die "Ошибка при подключении к БД! $DBI::errstr\n";
	
	return($dbh);
}

1;
