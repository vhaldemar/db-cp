package Auctions;
use strict;
use warnings;
use CGI qw(:standard *table);
use Shared;
use POSIX qw(ceil);

sub get {
	my $pageParams = shift;
	my $myAuctions = $pageParams->{page} eq 'myAuctions';
	my $page = param('page');
	Shared::IsNumber($page) or $page = 0;
	my $user = $pageParams->{session} ? $pageParams->{session}->param('id') : '';
	my $inner;
	my $query;

	my $dbh = Shared::ConnectDB();
	my $sth;

	if ($myAuctions && $user) {
		$query = qq{
			SELECT COUNT(*)
				FROM AUCTIONS
			WHERE seller = ?
		};

		$sth = $dbh->prepare($query);
		$sth->execute($user);
	} else  {
		$query = qq{
			SELECT COUNT(*)
				FROM AUCTIONS
		};

		$sth = $dbh->prepare($query);
		$sth->execute();
	}

	my $ref = $sth->fetchrow_hashref();
	my $number = $ref->{count};

	if ($number) {
		my $all = calculatePage($number);
		$page = $all if $page > $all;
		my $offset = $page * $Config::auctionsOnPage;
	
		if ($myAuctions && $user) {
			$query = qq{
				SELECT a.id, u.login, a.seller, max(bigger_date(datetime, start)) as timestamp,
					a.name, (
						SELECT bid
							FROM bids
							WHERE bids.auction = a.id
							ORDER BY datetime DESC
							LIMIT 1
					) last_bid
				FROM bids b RIGHT JOIN auctions a
				ON b.auction = a.id JOIN users u
				ON u.id = a.seller
				WHERE a.seller = ?
				GROUP BY a.id, u.login
				ORDER BY timestamp DESC
				LIMIT $Config::auctionsOnPage OFFSET $offset
			};
			$sth = $dbh->prepare($query);
			$sth->execute($user);
		} else {
			$query = qq{
				SELECT a.id, u.login, a.seller, max(bigger_date(datetime, start)) as timestamp,
					a.name, (
						SELECT bid
							FROM bids
							WHERE bids.auction = a.id
							ORDER BY datetime DESC
							LIMIT 1
					) last_bid
				FROM bids b RIGHT JOIN auctions a
				ON b.auction = a.id JOIN users u
				ON u.id = a.seller
				GROUP BY a.id, u.login
				ORDER BY timestamp DESC
				LIMIT $Config::auctionsOnPage OFFSET $offset
			};
			$sth = $dbh->prepare($query);
			$sth->execute();
		}
	
		$inner .= printTable($sth);
		$inner .= paginator($all, $page, $pageParams->{page});
	} else {
		$inner .= $myAuctions ?
			'Вы еще не создавали аукионов'
			:
			'Странно. Но на сайте нет аукционов';
	}
	
	return div({-id => 'bids'}, $inner).$\;
}

sub paginator {
	my ($all, $page, $pageName) = @_;

	if (!$all) {
		return '';
	}
	my $inner = 'Аукционы: ';
	for (my $i = 0; $i <= $all; $i++) {
		my $a .= ($i*$Config::auctionsOnPage + 1).'-'.(($i+1)*$Config::auctionsOnPage);
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
	my $div = $number / $Config::auctionsOnPage;
	my $int = int $number / $Config::auctionsOnPage;

	if ($div == $int) {
		$int--;
	}
	return $int;
}

sub printTable {
	my ($sth) = shift;
	my $inner .= start_table({-class => 'auctionTable'});

	while (my $ref = $sth->fetchrow_hashref()) {
		$inner .=Tr({-class => 'auctionRow'},
			td(
				{-class=>'timestamp'},
				"Обновлен: $ref->{timestamp}",
			),
			td(
				{-class=>'login'},
				'Создатель: '.a(
					{-href => "?user=$ref->{seller}"},
					$ref->{login},
				),
			),
			td(
				{-class=>'lastBid'},
				$ref->{last_bid} ?
					"Посл. ставка: $ref->{last_bid} $Config::currency"
					: "Cтавок нет"
			),
		);

		$inner .= Tr({-class => 'auctionRow'},td(
			{-colspan=>3},
			'Название: '.a(
				{-href=>"?auction=$ref->{id}"},
				$ref->{name},
			),
		));

		$inner .= Tr(td(
			{-colspan=>3, -class => 'spacing'},
			'&nbsp;'
		));

		
	}
	$inner .= end_table();
	return $inner;
} 


1;
