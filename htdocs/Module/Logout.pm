package Logout;
use strict;
use warnings;
use CGI qw(:standard);

sub get {
	my $pageParams = shift;
	$pageParams->{redirect} = '/?main';

	killSession($pageParams);
	return '';
}

sub killSession {
	my $pageParams = shift;

	$pageParams->{session}
		and $pageParams->{session}->clear()
		and $pageParams->{session}->delete()
		and $pageParams->{session} = undef;
}

1;
