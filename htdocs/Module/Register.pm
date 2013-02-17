package Register;
use strict;
use warnings;

use CGI qw(:standard);
use DBI;
use Shared;
use Digest::MD5 qw(md5_hex);

my $fieldSize = 30;

sub addUser { 
	my ($login, $password, $email) = @_;
	$password = md5_hex($password);
	my $insertUser = qq!
		INSERT INTO users(
			login, password, email, registration)
		VALUES (?, ?, ?, ?);
	!;

	my $dbh = Shared::ConnectDB();
	my $sth = $dbh->prepare($insertUser);
	$sth->execute($login, $password, $email, scalar localtime);
	$dbh->disconnect();

	if ($DBI::errstr) {
		$DBI::errstr;
	} else {
		p(
			"Вы были успешно зарегистрированы! Сейчас вас перенаправят на страницу авторизации."
		) . script(
			qq(
				var delay = 5000;
				setTimeout("document.location.href='/?auth'", delay);
			)
		);
	}
}

sub get { 
	my $login = Shared::Escape(param('login'));
	my $password = Shared::Escape(param('password'));
	my $passwordSecond = Shared::Escape(param('password_second'));
	my $email = Shared::NormalEmail(param('email'));
	my $isSend = param('register');
	my @errors;
	my $inner;

	if ($isSend) {
		push @errors, "Заполните имя пользователя!"
			if !$login;
		push @errors, "Заполните пароль!"
			if !$password;
		push @errors, "Повторите пароль!"
			if !$passwordSecond;
		push @errors, "Заполните почту!"
			if !$email;
		push @errors, "Пароли не совпадают!"
			if defined $password
				and defined $passwordSecond
				and $password ne $passwordSecond;
	}

	if ($isSend && !@errors) {
		my $selectUser = qq(
			SELECT login
				FROM users
			WHERE login = ?
		);
	
		my $dbh = Shared::ConnectDB();
		my $sth = $dbh->prepare($selectUser);
		$sth->execute($login);

		if ($sth->rows()) {
			push @errors, 'Пользователь с таким именем уже существует!';
		} else {
			return div({-id => 'registration'}, addUser($login, $password, $email).$\);
		}
		$dbh->disconnect();
	}

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
			td({-class => 'change'},
				submit(
					-name => 'Зарегистрироваться',
				)
			),
		),
		map {Tr(td({-colspan => 2},Shared::error($_)))} @errors,
	);
	
	$inner .= end_form();
	return div({-id => 'registration'}, $inner).$\;
}

sub print {
	my ($isLogin) = shift;
	print get($isLogin);
}

1;
