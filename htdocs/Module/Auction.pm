package Auction;
use strict;
use warnings;
use CGI qw(:standard);
use Shared;

sub get {
	my $pageParams = shift;
	my $auction = Shared::Escape(param('auction')) || '';
	my $user = $pageParams->{session} ? $pageParams->{session}->param('id') : '';
	my $inner;

	if ($auction) {
		my $query = qq{
			SELECT seller, buyer, u.login, starting_price, min_step, description, start, "end", a.name
				FROM auctions a, users u
			WHERE a.id = ? and u.id = seller
		};
		
		my $dbh = Shared::ConnectDB();
		my $sth = $dbh->prepare($query);
		$sth->execute($auction);

		if (my $ref = $sth->fetchrow_hashref()) {
			$query = qq{
				SELECT count(*)
					FROM bids
				WHERE auction = ?
			};
			$sth = $dbh->prepare($query);
			$sth->execute($auction);
			my $count = $sth->fetchrow_hashref()->{'count'};

			$inner .= printTable($ref, $user, $auction, $count);
		} else {
			$pageParams->{unauthorizedAction} = 'Такого аукциона не существует!';
		}
		
	} else {
		$pageParams->{unauthorizedAction} = 'Не указан аукцион';
	}

	return div({-id => 'user'}, $inner).$\;
}

sub printTable {
	my ($r, $user, $auction, $count) = @_;
	my $inner;
	
	my $text = Shared::bbCode($r->{description});

	$inner .= Tr(td({-colspan=>2}, h3({-class=>'auctionName'}, $r->{name})));
	$inner .= Tr(
		td('Продавец:'),
		td(a(
			{-href=>"?user=$r->{seller}"},
			$r->{login}
		)),
	);
	$inner .= Tr(
		td('Победитель аукциона:'),
		td($r->{buyer}),
	) if $r->{buyer};
	$inner .= Tr(
		td("Cтартовая цена, $Config::currency:"),
		td($r->{starting_price}),
	);
	$inner .= Tr(
		td("Минимальный шаг, $Config::currency:"),
		td($r->{min_step}),
	);
	$inner .= Tr(
		td('Старт:'),
		td($r->{start}),
	);
	$inner .= Tr(
		td('Конец:'),
		td($r->{end}),
	);
	$inner .= Tr(
		td('Ставок:'),
		td($count),
	);
	$inner .= Tr(
		td(
			{-colspan => 2, -class => 'change'},
			a(
				{-href => "?deleteAuction=$auction"},
				'Удалить',
			),
		),
	) if $user and $user eq $r->{seller} and $count == 0;
	$inner .= Tr(
		td({-class=>'description', -colspan=>'2'},
			h4('Описаниe лота').p($text),
		),
	);

	return table({-class => 'auction'}, $inner);
}


1;
