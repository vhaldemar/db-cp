package Menu;
use strict;
use warnings;
use CGI qw(:standard);

sub get {
	my ($isLogin) = shift;

	my $inner = 'This is a menu'.$\;
	$inner .= li("First href").$\;
	$inner .= li("Second href").$\;

	if ($isLogin) {
		
	} else {

	}

	return div({-id => 'menu'}, $inner).$\;
}

sub print { 
	my ($isLogin) = shift;
	print get($isLogin);
}

1;
