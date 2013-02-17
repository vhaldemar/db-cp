package Menu;
use strict;
use warnings;
use CGI qw(:standard);
use modules;
use Shared;
require 'Module/Events.pm';

sub get {
	my $pageParams = shift;
	my $inner;

	my $menu;
	if ($pageParams->{session}) {
		$menu = Modules::getLoginMenu();
	} else {
		$menu = Modules::getNonLoginMenu();
	}

	foreach (@{$menu}) {
		if ($_->{name} eq 'События') {
			$_->{name} .= ' ('.Events::getUnreaded($pageParams).')';
		}
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

1;
