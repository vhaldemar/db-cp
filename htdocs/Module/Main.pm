package Main;
use strict;
use warnings;
use CGI qw(:standard);
use Shared;

sub get {
	my $pageParams = shift;

	my $inner = 'This is a main page';

	if ($pageParams->{session}) {
		$inner .= " (login)";
	} else {
		$inner .= " (not login)";
	}

	$inner .= p('Параметры: ' . join (', ', param()));

	return div({-id => 'main'}, $inner).$\;
}

1;
