#!/usr/bin/perl -w
package Modules;
use strict;
use CGI qw(:standard);
use Shared;
use config;

my (@login, @nonLogin);
my (%pages, %modules);
# Модули, которые следует выводить на каждом типе страницы
BEGIN {
%pages = (
	main => {
		modules => [
			{
				module => 'Main',
			},
		],
		menu => {
			inMenu => 'all',
			menuName => 'Главная',
			menuNumber => '1',
		},
	},
	auth => {
		modules => [
			{
				module => 'Auth',
			}
		],
		menu => {
			inMenu => 'nonLogin',
			menuName => 'Авторизация',
			menuNumber => '2',
		},
	},
	register => {
		modules => [
			{
				module => 'Register',
			},
		],
		menu => {
			inMenu => 'nonLogin',
			menuName => 'Регистрация',
			menuNumber => '3',
		},
	},
	auctions => {
		modules => [
			{
				module => 'Auctions',
			},
		],
		menu => {
			inMenu => 'all',
			menuName => 'Аукционы',
			menuNumber => '4',
		},
	},
	search => {
		modules => [
			{
				module => 'Search',
			},
		],
		menu => {
			inMenu => 'all',
			menuName => 'Поиск',
			menuNumber => '5',
		},
	},
	user => {
		modules => [
			{
				module => 'User',
			},
		],
		menu => {
			inMenu => 'login',
			menuName => 'Профиль',
			menuNumber => '6',
		},
	},
	auction => {
		modules => [
			{
				module => 'Auction',
			},
		],
		menu => {
			inMenu => 'no',
			menuName => 'Аукцион',
			menuNumber => '',
		},
	},
	my_auctions => {
		modules => [
			{
				module => 'Auction',
			},
		],
		menu => {
			inMenu => 'login',
			menuName => 'Мои аукционы',
			menuNumber => '7',
		},
	},
);

while (my ($page, $pageParams) = each %pages) {
	my $params = $pageParams->{menu};
	if ($params->{inMenu} eq 'all' or $params->{inMenu} eq 'login') {
		push @login, {
				name => $params->{menuName},
				dest => ($params->{dest} || "?$page"),
				number => $params->{menuNumber},
			};
	}
	if ($params->{inMenu} eq 'all' or $params->{inMenu} eq 'nonLogin') {
		push @nonLogin, {
				name => $params->{menuName},
				dest => ($params->{dest} || "?$page"),
				number => $params->{menuNumber},
			};
	}
}

@login = sort {$a->{number} <=> $b->{number}} @login;
@nonLogin = sort {$a->{number} <=> $b->{number}} @nonLogin;

%modules = (
	Main => {
			include => 'Module/Main.pm',
			name => 'Главная страница',
			wrap => 'yes',
		},
	Auth => {
			include => 'Module/Auth.pm',
			name => 'Авторизация',
			wrap => 'yes',
		},
	Register => {
			include => 'Module/Register.pm',
			name => 'Регистрация',
			wrap => 'yes',
		},
	Auctions => {
			include => 'Module/Auctions.pm',
			name => 'Аукционы',
			wrap => 'yes',
		},
	Search => {
			include => 'Module/Search.pm',
			name => 'Поиск',
			wrap => 'yes',
		},
	User => {
			include => 'Module/User.pm',
			name => 'Профиль',
			wrap => 'yes',
		},
	Auction => {
			include => 'Module/Auction.pm',
			name => 'Аукцион',
			wrap => 'yes',
		},
);
} # END OF BEGIN SECTION

sub getModule {
	my ($module, $wrap) = shift;
	my $params = $modules{$module}
		or return Shared::error('Wrong module name: '.$module);
	my $include = $params->{include};
	-e $Config::root.'/'.$include
		or return Shared::error('No such file: '.$include);
	
	require $include
		or return Shared::Error($!);

	my $inner = eval($module."::get()");

	if ($wrap or $params->{wrap}) {
		$inner = div(
			{-class => "module_wrapper $module\_wrapper"},
			h1(
				{-class => "module_name $module\_name"},
				$params->{name}
			),
			$inner,
		);
	}

	return $inner;
}

sub isPage {
	my $page = shift;
	return defined $pages{$page};
}

sub getPage {
	my $page = shift;
	isPage($page)
		or return Shared::error('Wrong page name: '.$page);
	my $modules = $pages{$page}->{modules};
	my $inner;

	foreach (@{$modules}) {
		my $module = $_->{module};
		my $wrap = $_->{wrap};
		$inner .= getModule($module, $wrap);
	}

	return div({-id => 'content'}, $inner);
}

sub getPages {
	return \%pages;
}

sub getLoginMenu {
	return \@login;
};

sub getNonLoginMenu {
	return \@nonLogin;
};

1;
