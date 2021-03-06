package Auth;
use strict;
use warnings;
use CGI qw(:standard);
use CGI::Cookie;
use CGI::Session;
use Shared;
use Digest::MD5 qw(md5_hex);

sub get {
	my $pageParams = shift;
	if ($pageParams->{session}) {
		$pageParams->{unauthorizedAction} = 'Вы уже зашли в систему!';
		return '';
	}

	my $login = Shared::Escape(param('login'));
	my $password = Shared::Escape(param('password'));
	my @errors;
	my $inner;

	push @errors, "Заполните имя пользователя!"
		if defined $login and !$login;
	push @errors, "Заполните пароль!"
		if defined $password and !$password;
	push @errors, "Ваша сессия истекла!"
		if defined param('expired');
	
	if ($login && $password) {
		my $selectUser = qq(
			SELECT id, login, name
				FROM users
			WHERE login = ? and password = ?
		);

		$password = md5_hex($password);
		my $dbh = Shared::ConnectDB();
		my $sth = $dbh->prepare($selectUser);
		$sth->execute($login, $password);
		
		if (my $ref = $sth->fetchrow_hashref()) {
			my $session = new CGI::Session();
			$session->param('name', $ref->{name} || '');
			$session->param('login', $ref->{login});
			$session->param('id', $ref->{id});

			my $name = $ref->{name} || $ref->{login};
			$inner .= p(
				"Добрый день, $name. В течение 5 секунд вы будете перенаправлены на главную страницу."
			) . script(
				qq(
					var delay = 5000;
					setTimeout("document.location.href='/?main'", delay);
				)
			);
			$pageParams->{header} = $session->header(-location => '?main');
			return div({-id => 'login'}, $inner).$\;
		} else {
			push @errors, 'Неправильное имя пользователя или пароль!';
		}

	}

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

1;
