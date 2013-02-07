package Auth;
use strict;
use warnings;
use CGI qw(:standard);
use Shared;

sub get {
	my $login = Shared::Escape(param('login'));
	my $password = Shared::Escape(param('password'));
	my @errors;

	push @errors, "Заполните имя пользователя!"
		if defined $login and !$login;
	push @errors, "Заполните пароль!"
		if defined $password and !$password;
	
	if ($login && $password) {
		
	}

	my $inner;
	$inner .= start_form(
		-name => 'auth',
		-method => 'post',
		-action => '/',
	);

	$inner .= hidden(
		-name => 'auth',
		-value => 'send',
	);

	$inner .= table(
		Tr(
			td("Имя пользователя:"),
			td(textfield(
				-name => 'login',
				-size => 30,
				-maxlength => 30,
			))
		),
		Tr(
			td("Пароль:"),
			td(password_field(
				-name => 'password',
				-value => '',
				-size => 30,
				-maxlength => 32,
			)),
		),
		Tr(
			td(checkbox(
				'keep_login',
				0,
				'',
				'Оставаться в системе',
			)),
			td({-align => 'right'},
				submit(
					-name => 'Войти',
				)
			),
		),
		map {Tr(td(Shared::error($_)))} @errors,
	);
	
	$inner .= end_form();
	return div({-id => 'login'}, $inner).$\;
}

sub print {
	my ($isLogin) = shift;
	print get($isLogin);
}

1;
