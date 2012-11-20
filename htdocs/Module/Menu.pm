package Menu;
use strict;
use warnings;
use CGI qw(:standard);
use modules;

sub get {
	my ($isLogin) = shift;
	my $inner;

	my $menu;
	if ($isLogin) {
		$menu = Modules::getLoginMenu();
	} else {
		$menu = Modules::getNonLoginMenu();
	}

	foreach (@{$menu}) {
		$inner .= li(
			{-class => 'menu_element'},
			a({-href => $_->{dest}}, $_->{name}),
		),
	}

	return div(
		{
			-id => 'menu',
			-class => 'sidebar',
		},
		ul(
			{-class => 'menu_list'},
			$inner
		),
	).$\;
}

sub print {
	my ($isLogin) = shift;
	print get($isLogin);
}

1;
