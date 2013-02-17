#!/usr/bin/perl -w
package Modules;
use strict;
use CGI qw(:standard);
use Shared;
use config;
use 5.8.0;
use Readonly;

# Модули, которые следует выводить на каждом типе страницы
my (@login, @nonLogin);

Readonly my %pages => (
	main => {
		modules => [{module => 'Main'}],
		menu => {
			inMenu => 'all',
			menuName => 'Главная',
			menuNumber => '1',
		},
	},
	auth => {
		modules => [{module => 'Auth'}],
		menu => {
			inMenu => 'nonLogin',
			menuName => 'Авторизация',
			menuNumber => '2',
		},
	},
	logout => {
		modules => [{module => 'Logout'}],
		menu => {
			inMenu => 'login',
			menuName => 'Выход',
			menuNumber => '100',
		},
	},
	register => {
		modules => [{module => 'Register'}],
		menu => {
			inMenu => 'nonLogin',
			menuName => 'Регистрация',
			menuNumber => '3',
		},
	},
	search => {
		modules => [{module => 'Search'}],
		menu => {
			inMenu => 'all',
			menuName => 'Поиск',
			menuNumber => '4',
		},
	},
	user => {
		modules => [
			{
				module => 'User',
				wrap => 'cut',
			},
			{
				module => 'Guarantees',
				wrap => 'cut',
			},
		],
		menu => {
			inMenu => 'login',
			menuName => 'Профиль',
			menuNumber => '5',
		},
	},
	events => {
		modules => [{module => 'Events'}],
		menu => {
			inMenu => 'login',
			menuName => 'События',
			menuNumber => '6',
		},
	},
	auctions => {
		modules => [{module => 'Auctions'}],
		menu => {
			inMenu => 'all',
			menuName => 'Аукционы',
			menuNumber => '7',
		},
	},
	myAuctions => {
		modules => [{module => 'Auctions'}],
		menu => {
			inMenu => 'login',
			menuName => 'Мои аукционы',
			menuNumber => '8',
		},
	},
	addAuction => {
		modules => [{module => 'AddAuction'}],
		menu => {
			inMenu => 'login',
			menuName => 'Создать аукцион',
			menuNumber => 9,
		}
	},
	deleteAuction => {
		modules => [{module => 'DeleteAuction'}],
		menu => {inMenu => 'no'},
	},
	auction => {
		modules => [
			{module => 'Auction'},
			{module => 'Comments', wrap => 'cut'},
			{module => 'Bids', wrap => 'cut'},
		],
		menu => {inMenu => 'no'},
	},
	changeUserInfo => {
		modules => [{module => 'ChangeUserInfo'}],
		menu => {inMenu => 'no'},
	},
	addWarranty => {
		modules => [{module => 'AddWarranty'}],
		menu => {inMenu => 'no'},
	},
	deleteWarranty => {
		modules => [{module => 'DeleteWarranty'}],
		menu => {inMenu => 'no'},
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

Readonly my %modules => (
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
		name => 'Пользовательская информация',
		wrap => 'yes',
	},
	ChangeUserInfo => {
		include => 'Module/ChangeUserInfo.pm',
		name => 'Изменение пользовательской информации',
		wrap => 'yes',
	},
	Guarantees => {
		include => 'Module/Guarantees.pm',
		name => 'Поручительства',
		wrap => 'yes',
	},
	AddWarranty => {
		include => 'Module/AddWarranty.pm',
		name => 'Добавить поручительство',
		wrap => 'no',
	},
	DeleteWarranty => {
		include => 'Module/DeleteWarranty.pm',
		name => 'Удалить поручительство',
		wrap => 'no',
	},
	Events => {
		include => 'Module/Events.pm',
		name => 'События',
		wrap => 'yes',
	},
	Auction => {
		include => 'Module/Auction.pm',
		name => 'Аукцион',
		wrap => 'yes',
	},
	Comments => {
		include => 'Module/Comments.pm',
		name => 'Комментарии',
		wrap => 'yes',
	},
	Bids => {
		include => 'Module/Bids.pm',
		name => 'Ставки',
		wrap => 'yes',
	},
	AddAuction => {
		include => 'Module/AddAuction.pm',
		name => 'Создание аукциона',
		wrap => 'yes',
	},
	DeleteAuction => {
		include => 'Module/DeleteAuction.pm',
		name => 'Удаление аукциона',
		wrap => 'yes',
	},
	Logout => {
		include => 'Module/Logout.pm',
		name => 'Выход',
		wrap => 'no',
	},
	UnauthorizedAction => {
		include => 'Module/UnauthorizedAction.pm',
		name => 'Несанкционированное действие',
		wrap => 'yes',
	},
);

sub getModule {
	my ($module, $wrap, $pageParams) = @_;
	$wrap ||= 'no';
	
	my $params = $modules{$module}
		or return Shared::error('Wrong module name: '.$module);
	$params->{wrap} ||= 'no';
	
	my $include = $params->{include};
	-e $Config::root.'/'.$include
		or return Shared::error('No such file: '.$include);
	
	require $include
		or return Shared::Error($!);

	my $evalStr = $module.'::get($pageParams)';
	my $inner = eval($evalStr);

	if($wrap eq 'cut' or $params->{wrap} eq 'cut') {
		$pageParams->{css}{'cut.css'} = 1;
		$pageParams->{javascript}{'jquery-1.9.1.min.js'} = 0;
		$pageParams->{javascript}{'cut.js'} = 10000;

		$inner = div(
			{-class => "module_wrapper $module\_wrapper"},
			a(
				{-class => "module_name $module\_name cat_link", -href => '#'},
				h2($params->{name}),
			),
			div(
				{-class => "cat_cont"},
				$inner,
			),
		);
	} elsif ($wrap eq 'yes' or $params->{wrap} eq 'yes') {
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
	my ($page, $pageParams) = @_;
	isPage($page)
		or return Shared::error('Wrong page name: '.$page);

	my $modules = $pages{$page}->{modules};
	my $inner;
	foreach (@{$modules}) {
		my $module = $_->{module};
		my $wrap = $_->{wrap};
		$inner .= getModule($module, $wrap, $pageParams);

		if ($pageParams->{unauthorizedAction}){
			my $module = 'UnauthorizedAction';
			my $wrap = $modules{UnauthorizedAction}->{wrap};
			$inner = getModule($module, $wrap, $pageParams);
			last;
		}

		$pageParams->{redirect} and last;
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
