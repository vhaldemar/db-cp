package Main;
use strict;
use warnings;
use CGI qw(:standard);

sub get { 
	my ($isLogin) = shift;

	my $inner = 'This is a main page';
	if ($isLogin) {

	} else {

	}

	return div({-id => 'main'}, $inner).$\;
}

sub print {
	my ($isLogin) = shift;
	print get($isLogin);
}

1;
