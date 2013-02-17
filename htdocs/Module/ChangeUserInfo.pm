package ChangeUserInfo;
use strict;
use warnings;
use CGI qw(:standard *table);
use Shared;
use Digest::MD5 qw(md5_hex);
use DBI;

my $fieldSize = 30;

sub get {
	my $pageParams = shift;
	my $user = $pageParams->{session} ? $pageParams->{session}->param('id') : undef;
	my $inner;
	my @errors;
	my $params;

	if ($user && defined param('changeUserInfo')) {
		$params = checkParams(\@errors, $user);
		if (!@errors) {
			updateParams($params, $user);
			$pageParams->{redirect} = '?user';
			return '';
		}
	}

	if ($user) {
		my $query = qq{
			SELECT login, email, city, name, phone, adress
				FROM users
			where id = ?
		};
		
		my $dbh = Shared::ConnectDB();
		my $sth = $dbh->prepare($query);
		$sth->execute($user);

		if (my $ref = $sth->fetchrow_hashref()) {
			$inner .= printForm($ref, $params, \@errors);
		} else {
			$pageParams->{unauthorizedAction} = 'Такого пользователя не существует';
		}
	} else {
		$pageParams->{unauthorizedAction} = 'Не указан пользователь';
	}

	return div({-id => 'changeUserInfo'}, $inner).$\;
}

sub updateParams {
	my ($p, $user) = @_;

	my $q = $p->{newPassword} ? qq(
		UPDATE users
			SET password=?, email=?, city=?, name=?, phone=?, adress=?
		WHERE id=?;
	) : qq(
		UPDATE users
			SET email=?, city=?, name=?, phone=?, adress=?
		WHERE id=?;
	);

	my $dbh = Shared::ConnectDB();
	my $sth = $dbh->prepare($q);
	if ($p->{newPassword}) {
		$sth->execute(
			md5_hex($p->{newPassword}),
			$p->{email},
			$p->{city} || undef,
			$p->{name} || undef,
			$p->{phone} || undef,
			$p->{adress} || undef,
			$user,
		);
	} else {
		$sth->execute(
			$p->{email} || undef,
			$p->{city} || undef,
			$p->{name} || undef,
			$p->{phone} || undef,
			$p->{adress} || undef,
			$user,
		);
	}
}

sub checkParams {
	my ($errors, $user) = @_;
	my @params = qw/email city name phone adress password second newPassword/;
	my %r;
	foreach (@params) {
		$r{$_} = Shared::Escape(param($_)) || '';
	}

	push @{$errors}, "Заполните почту!"
		if !$r{email};
	push @{$errors}, "Пароли не совпадают!"
		if $r{newPassword} ne $r{second};

	if ($r{password}) {
		my $pass = md5_hex($r{password});
		my $q = qq(
			SELECT password
				FROM users
			WHERE id = ?
		);

		my $dbh = Shared::ConnectDB();
		my $sth = $dbh->prepare($q);
		$sth->execute($user);
		
		if (my $ref = $sth->fetchrow_hashref()) {
			$ref->{password} ne $pass
				and push @{$errors}, 'Неправильно введен пароль!';
		} else {
			push @{$errors}, 'Пользователя с таким id не существует!';
		}
	} else {
		push @{$errors}, 'Введите пароль для подвтерждения!';
	}

	if (!$r{newPassword}) {
		delete $r{newPassword};
		delete $r{second};
	} 

	return \%r;
}

sub printForm {
	my ($r, $p, $errors) = @_;
	my $inner;
	
	$inner .= start_form(
		-name => 'newInfo',
		-method => 'post',
		-action => '/?changeUserInfo',
	);
	
	$inner .= start_table({-class => 'info'});

	$inner .= hidden(
		-name => 'changeUserInfo',
		-value => 'send',
	);

	$inner .= Tr(
		td('Логин:'),
		td($r->{login}),
	);
	$inner .= Tr(
		td('Имя пользователя:'),
		td(textfield(
			-name => 'name',
			-size => $fieldSize,
			-value => $p->{name} || $r->{name} || '',
			-maxlength => 30,
		))
	);
	$inner .= Tr(
		td('Почта*:'),
		td(textfield(
			-name => 'email',
			-size => $fieldSize,
			-value => $p->{email} || $r->{email} || '',
			-maxlength => 30,
		))
	);
	$inner .= Tr(
		td('Город:'),
		td(textfield(
			-name => 'city',
			-size => $fieldSize,
			-value => $p->{city} || $r->{city} || '',
			-maxlength => 30,
		))
	);
	$inner .= Tr(
		td('Телефон:'),
		td(textfield(
			-name => 'phone',
			-size => $fieldSize,
			-value => $p->{phone} || $r->{phone} || '',
			-maxlength => 30,
		))
	);
	$inner .= Tr(
		td('Почтовый адрес:'),
		td(textarea(
			-name => 'adress',
			-default => $p->{adress} || $r->{adress} || '',
		))
	);
	$inner .= Tr(
		td('Дата регистрации:'),
		td($r->{registration}),
	) if $r->{registration};

	$inner .=Tr(
		td("Новый пароль:"),
		td(password_field(
			-name => 'newPassword',
			-value => '',
			-size => $fieldSize,
			-maxlength => 32,
		)),
	);

	$inner .= Tr(
		td("Повторите пароль:"),
		td(password_field(
			-name => 'second',
			-value => '',
			-size => $fieldSize,
			-maxlength => 32,
		)),
	);

	$inner .= Tr(
		td(
			{-colspan => 2, -align => 'center'},
			hr({-width => '90%'}),
		),
	);
	
	$inner .= Tr(
		td("Пароль для подтверждения:"),
		td(password_field(
			-name => 'password',
			-value => '',
			-size => $fieldSize,
			-maxlength => 32,
		)),
	);
	
	$inner .= Tr(
		td(),
		td({-class => 'change'},
			submit(
				-name => 'Изменить',
			)
		),
	);

	map {$inner .= Tr(td({-colspan => 2}, Shared::error($_)))} @{$errors};
	$inner .= end_table() . end_form();
	return $inner;
}


1;
