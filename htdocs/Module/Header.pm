package Header;
use strict;
use warnings;
use CGI qw(:standard);
use Shared;

sub get {
	my $pageParams = shift;
	my $inner;

	my $session = $pageParams->{session};
	if ($session) {
		$inner .= p(
			"Пользователь: ".($session->param('name') || $session->param('login'))
		) . p(
				a(
					{-href => '/?logout'},
					'Выйти',
				),
		);
	} else {

	}

	return div({-id => 'header'}, $inner).$\;
}

1;
