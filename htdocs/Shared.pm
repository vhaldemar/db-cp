package Shared;
use strict;
use warnings;
use DBI;
use config;
use CGI qw(:standard);
use CGI::Session;
use POSIX qw(strftime);

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
	return if !defined $email;
	$email = lc $email;
	$email =~ s/^\s+//;
	$email =~ s/\s+$//;

	if (! ($email =~ /^[^@]+\@(?:[^.]+\.)*[^.]+$/)) {
		$email = '';
	}
	return $email;
}

sub error {
	my $text = shift;
	return p({-class => 'error_text'}, $text);
}

sub Escape {
	my $str = shift;
}

sub getSession {
	my $s = CGI::Session->load();
	if ($s->is_expired()) {
		return $s;
	} elsif ($s->is_empty()) {
		return undef;
	} else {
		return $s;
	}
}

sub GetDate {
	return strftime("%Y-%m-%d", localtime);
}

sub GetTime {
	return strftime("%H:%M:%S", localtime);
}

sub GetDateTime {
	return strftime("%Y-%m-%d %H:%M:%S", localtime);
}

sub CheckImage {
	my $image = shift;
	return $image;
}

sub IsNumber {
	my $num = shift;
	if ($num =~ /^\-?\d+$/) {
		return $num;
	} else {
		return undef;
	}
}

sub bbCode {
	my $text = shift;
	$text =~ s/\[img\](.+?)\[\/img\]/<a href="$1"><img src="$1" class="auctionImage"><\/a>/g;
	$text =~ s/\n/\n<br\/>\n/g;
	return $text;
}

1;
