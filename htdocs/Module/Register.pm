package Register;
use strict;
use warnings;

use CGI qw(:standard);
use Shared;


my $fieldSize = 30;

sub get {
	my $login = Shared::Escape(param('login'));
	my $password = Shared::Escape(param('password'));
	my $passwordSecond = Shared::Escape(param('password_second'));
	my $email = Shared::NormalEmail(param('email'));
	my @errors;

	push @errors, "Заполните имя пользователя!"
		if defined $login and !$login;
	push @errors, "Заполните пароль!"
		if defined $password and !$password;
	push @errors, "Заполните почту!"
		if defined $email and !$email;
	push @errors, "Пароли не совпадают!"
		if defined $password
			and defined $passwordSecond
			and $password ne $passwordSecond;

	if ($login and !@errors) {
		
	}

	my $inner;
	$inner .= start_form(
		-name => 'register',
		-method => 'post',
		-action => '/',
	);

	$inner .= hidden(
		-name => 'register',
		-value => 'send',
	);

	$inner .= table(
		Tr(
			td("Имя пользователя*:"),
			td(textfield(
				-name => 'login',
				-size => $fieldSize,
				-maxlength => 30,
			))
		),
		Tr(
			td("Пароль*:"),
			td(password_field(
				-name => 'password',
				-value => '',
				-size => $fieldSize,
				-maxlength => 32,
			)),
		),
		Tr(
			td("Повторите пароль*:"),
			td(password_field(
				-name => 'password_second',
				-value => '',
				-size => $fieldSize,
				-maxlength => 32,
			)),
		),
		Tr(
			td("Электронная почта*:"),
			td(textfield(
				-name => 'email',
				-size => $fieldSize,
				-maxlength => 100,
			)),
		),
		Tr(
			td(),
			td({-align => 'right'},
				submit(
					-name => 'Зарегистрироваться',
				)
			),
		),
		map {Tr(td(Shared::error($_)))} @errors,
	);
	
	$inner .= end_form();
	return div({-id => 'registration'}, $inner).$\;
}

sub print {
	my ($isLogin) = shift;
	print get($isLogin);
}

1;
