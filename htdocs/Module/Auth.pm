package Footer;
use strict;
use warnings;
use CGI qw(:standard);

sub get {
	my ($isLogin) = shift;

	my $inner = 'This is a footer';
	if ($isLogin) {

	} else {

	}

	return div({-id => 'footer'}, $inner).$\;
}

sub print {
	my ($isLogin) = shift;
	print get($isLogin);
}

1;
