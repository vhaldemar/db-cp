package User;
use strict;
use warnings;
use CGI qw(:standard);
use Shared;

sub get {
	my $pageParams = shift;
	my $user = Shared::Escape(param('user')) || '';
	my $thisUser = $pageParams->{session} ? $pageParams->{session}->param('id') : '';
	my $myPage = $thisUser eq $user ? 1 : 0;
	$user ||= $thisUser;
	my $inner;

	if ($user) {
		my $query = qq{
			SELECT id, login, password, email, city, name, phone, adress, level, registration
				FROM users
			where id = ?
		};
		
		my $dbh = Shared::ConnectDB();
		my $sth = $dbh->prepare($query);
		$sth->execute($user);

		if (my $ref = $sth->fetchrow_hashref()) {
			$inner .= printTable($ref, $thisUser);
		} else {
			$pageParams->{unauthorizedAction} = 'Такого пользователя не существует';
		}

		
	} else {
		$pageParams->{unauthorizedAction} = 'Не указан пользователь';
	}

	return div({-id => 'user'}, $inner).$\;
}

sub printTable {
	my $r = shift;
	my $thisUser = shift;
	my $inner;
	$inner .= Tr(
		td('Логин:'),
		td($r->{login}),
	);
	$inner .= Tr(
		td('Имя пользователя:'),
		td($r->{name}),
	) if $r->{name};
	$inner .= Tr(
		td('Почта:'),
		td($r->{email}),
	);
	$inner .= Tr(
		td('Город:'),
		td($r->{city}),
	) if $r->{city};
	$inner .= Tr(
		td('Телефон:'),
		td($r->{phone}),
	) if $r->{phone};
	$inner .= Tr(
		td('Почтовый адрес:'),
		td($r->{adress}),
	) if $r->{adress};
	$inner .= Tr(
		td('Дата регистрации:'),
		td($r->{registration}),
	) if $r->{registration};
	$inner .= Tr(
		td(
			{-colspan => 2, -class => 'change'},
			a(
				{-href => '?changeUserInfo'},
				'Изменить',
			),
		),
	) if $thisUser;

	return table({-class => 'info'}, $inner);
}


1;
