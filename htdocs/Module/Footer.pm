package Footer;
use strict;
use warnings;
use CGI qw(:standard);

sub get {
	my $inner .= p('Параметры: ' . join (', ', param()));

	return div({-id => 'footer'}, $inner).$\;
}

sub print {
	my ($isLogin) = shift;
	print get($isLogin);
}

1;
