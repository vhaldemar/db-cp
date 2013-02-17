package Events;
use strict;
use warnings;
use CGI qw(:standard *table);
use Shared;
use Readonly;

Readonly my %eventTypes => (
	1 => 'Ваш аукцион закончился',
	2 => 'Вы выиграли аукцион',
	3 => 'Вам добавили поручительство',
	4 => 'Вам добавили отзыв',
	5 => 'В вашем аукционе новый комментарий',
);

sub getUnreaded {
	my $pageParams = shift;
	if (my $user = $pageParams->{session} ? $pageParams->{session}->param('id') : '') {
		my $query = qq{
			SELECT count(*)
				FROM events
			WHERE "user" = ? and readed = FALSE
		};
		
		my $dbh = Shared::ConnectDB();
		my $sth = $dbh->prepare($query);
		$sth->execute($user);
		return $sth->fetchrow_hashref()->{'count'};
		
	} else {
		return 0;
	}
}

sub addEvent {
	my ($user, $type, $text) = @_;
	my $query = qq{
		INSERT INTO events(
			"user", type, text, "timestamp", readed)
		VALUES (?, ?, ?, ?, FALSE);
	};

	my $dbh = Shared::ConnectDB();
	my $sth = $dbh->prepare($query);
	$sth->execute($user, $type, $text, Shared::GetDateTime());
	print $DBI::errstr;
}

sub get {
	my $pageParams = shift;
	my $user = $pageParams->{session} ? $pageParams->{session}->param('id') : '';
	my $page = param('page');
	Shared::IsNumber($page) or $page = 0;
	my $inner;

	if ($user) {
		my $query = qq{
			SELECT COUNT(*)
				FROM events
			WHERE "user" = ?
		};

		my $dbh = Shared::ConnectDB();
		my $sth = $dbh->prepare($query);
		$sth->execute($user);
		
		my $ref = $sth->fetchrow_hashref();
		my $number = $ref->{count};

		if ($number) {
			my $all = calculatePage($number);
			my $offset = $page * $Config::eventsPerPage;

			$query = qq{
				SELECT id, type, text, "timestamp", readed
				FROM events
				WHERE "user" = ?
				ORDER BY "timestamp" DESC
				LIMIT $Config::eventsPerPage OFFSET $offset
			};

			$sth = $dbh->prepare($query);
			$sth->execute($user);
			$inner .= printTable($sth);
			$inner .= paginator($all, $page, $pageParams->{page});
		} else {
			$inner .= p('Событий еще не происходило.');
		}
	} else {
		$pageParams->{unauthorizedAction} = 'Вы должны быть в системе для просмотра событий!';
	}

	return div({-id => 'guarantees'}, $inner).$\;
}

sub paginator {
	my ($all, $page, $pageName) = @_;
	if (!$all) {
		return '';
	}
	my $inner = 'Сообщения: ';
	for (my $i = 0; $i <= $all; $i++) {
		my $a .= ($i*$Config::eventsPerPage + 1).'-'.(($i+1)*$Config::eventsPerPage);
		if ($i != $page) {
			$a = a(
				{-href=>"?$pageName&page=$i"},
				$a
			);
		}
		$inner .= ($i == 0 ? '' :' | ').$a;
	}

	return div({-class=>'paginator'}, $inner);
}

sub calculatePage {
	my ($number) = @_;
	my $div = $number / $Config::eventsPerPage;
	my $int = int $number / $Config::eventsPerPage;

	if ($div == $int) {
		$int--;
	}
	return $int;
}

sub printTable {
	my ($sth) = shift;
	my $inner .= start_table({-class => 'eventsTable'});

	while (my $ref = $sth->fetchrow_hashref()) {
		$inner .=Tr({-class => 'eventRow'.($ref->{readed} ? '' : ' unread')},
			td(
				{-class=>'timestamp'},
				"Обновлен: $ref->{timestamp}",
			),
			td(
				{-class=>'type'},
				$eventTypes{$ref->{type}}
			),
		);

		$inner .= Tr({-class => 'eventRow'},
			td(
				{-colspan=>2},
				$ref->{text}
			),
		);

		$inner .= Tr(td(
			{-colspan=>3, -class => 'spacing'},
			'&nbsp;'
		));
	}
	$inner .= end_table();
	return $inner;
} 

1;
