package Guarantees;
use strict;
use warnings;
use CGI qw(:standard *table);
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
			SELECT u.login as guarantor, u.id as guarantorid, text, date, g.id
				FROM guarantee g, users u
			WHERE u.id = g.guarantor and g.user= ?
		};
		
		my $dbh = Shared::ConnectDB();
		my $sth = $dbh->prepare($query);
		$sth->execute($user);

		my $printForm = ($thisUser and $thisUser ne $user);
		if ($sth->rows() == 0) {
			$inner .= p('Никто еще не поручился за этого пользователя.');
		}
		while (my $ref = $sth->fetchrow_hashref()) {
			my $del;
			if ($thisUser eq $user){
				$del = 1;
			} elsif ( $thisUser eq $ref->{guarantorid} ) {
				$del = 1;
				$printForm = 0;
			}

			$inner .= printTable($ref, $del);
		}

		$printForm and $inner .= printForm($user, $thisUser);
	} else {
		$pageParams->{unauthorizedAction} = 'Не указан пользователь';
	}

	return div({-id => 'guarantees'}, $inner).$\;
}

sub printForm {
	my ($user, $thisUser) = @_;

	my $inner .= start_form(
		-name => 'addWarrantyForm',
		-method => 'post',
		-action => '/',
	);

	$inner .= hidden(
		-name => 'userId',
		-value => $user,
	);
	
	$inner .= hidden(
		-name => 'addWarranty',
		-value => 1,
	);

	$inner .= start_table({-class=>'addWarranty'});
	$inner .= Tr(td(h3('Поручиться за пользователя')));

	$inner .= Tr(td(textarea(
			-name => 'warrantyText',
			-default => '',
	)));
	$inner .= Tr(td({-class => 'change'},
		submit(
			-name => 'Добавить поручительство',
		)
	));

	$inner .= end_table();
	$inner .= end_form();
	return $inner;

}

sub printTable {
	my ($ref, $del) = @_;
	my $inner .= start_table({-class => 'guarantee'});

	$inner .=Tr(
		td(
			{-class=>'date'},
			$ref->{date},
		),
		td(
			{-class=>'username'},
			'Поручитель: '.$ref->{guarantor},
		),
		td(
			{-class=>'delete'},
			$del ? a(
				{-href => "?deleteWarranty=$ref->{id}"},
				'Удалить',
			) : '',
		),
	);

	$inner .= Tr(
		td(
			{-class => 'text', -colspan=>3},
			$ref->{text},
		),
	);
	

	$inner .= end_table();
	return $inner;
}


1;
