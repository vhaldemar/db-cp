package Header;
use strict;
use warnings;
use CGI qw(:standard);

sub get {
	my ($isLogin) = shift;

	my $inner = 'This is a header';
	if ($isLogin) {

	} else {

	}

	return div({-id => 'header'}, $inner).$\;
}

sub print {
	my ($isLogin) = shift;
	print get($isLogin);

}
1;
