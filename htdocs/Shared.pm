package Shared;
use strict;
use warnings;
use DBI;
use config;
use CGI qw(:standard);

sub ConnectDB {
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

sub NormalEmail {
	my $email = shift;
	$email = lc $email;
	$email =~ s/^\s+//;
	$email =~ s/\s+$//;

	if (! ($email =~ /^[^@]+\@(?:[^.].)*[^.]+$/)) {
		$email = '';
	}
	return $email;
}

sub error {
	my $text = shift;
	return p({-class => 'error_text'}, $text);
}

1;
