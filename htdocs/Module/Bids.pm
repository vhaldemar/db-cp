package Bids;
use strict;
use warnings;
use CGI qw(:standard *table);
use Shared;

sub get { 
	my $pageParams = shift;
	my $auction = Shared::Escape(param('auction')) || '';
	my $user = $pageParams->{session} ? $pageParams->{session}->param('id') : '';
	my $inner;
	my @errors;
	my $addBid = Shared::Escape(param('addBid')) || '';

	if ($auction) {
		my $query = qq{
			SELECT a.seller, a.buyer, a.min_step, starting_price, (
				SELECT bid
					FROM bids
					WHERE bids.auction = a.id
					ORDER BY datetime DESC
					LIMIT 1
			) last_bid, (
				SELECT "user"
					FROM bids
					WHERE bids.auction = a.id
					ORDER BY datetime DESC
					LIMIT 1
			) last_bidder
			FROM users u, auctions a
			WHERE a.id = ? and a.seller = u.id
		};
		
		my $dbh = Shared::ConnectDB();
		my $sth = $dbh->prepare($query);
		$sth->execute($auction);
		my $ref = $sth->fetchrow_hashref();
		my $lastBid = $ref->{last_bid} || $ref->{starting_price};
	
		my $okAdd;
		if ($user
			and $user ne $ref->{seller}
			and $user ne $ref->{last_bidder}
			and !$ref->{buyer}
		) {
			$okAdd = 1;
		}

		if ($addBid && $okAdd) {
			my $newBid = Shared::Escape(param('newBid')) || 0;
			if (!$newBid) {
				push @errors, 'Ставка не заполнена!';
			} elsif (!Shared::IsNumber($newBid)) {
				push @errors, 'Ставка должна состоять из цифр!';
			} elsif ($newBid <= $lastBid) {
				push @errors, 'Ставка должна превышать предыдущую!';
			} elsif ($newBid - $lastBid < $ref->{min_step}) {
				push @errors, "Ставка должна превосходить предыдущую как минимум на $ref->{min_step} $Config::currency";
			} else {
				$query = qq {
					INSERT INTO bids(auction, "user", bid, datetime)
					VALUES (?, ?, ?, ?);
				};

				my $sth2 = $dbh->prepare($query);
				$sth2->execute($auction, $user, $newBid, Shared::GetDateTime());
				$pageParams->{redirect} = "?auction=$auction";
				return '';
			}
		}

		if (!$ref->{last_bid}) {
			$inner .= p('Ставок еще нет.');
		}

		$inner .= printForm($auction, \@errors)
			if $okAdd;

		$inner .= printTable($auction) if $ref->{last_bid};

	} else {
		$pageParams->{unauthorizedAction} = 'Не указан аукцион';
	}

	return div({-id => 'bids'}, $inner).$\;
}

sub printForm {
	my ($auction, $errors) = @_;

	my $inner .= start_form(
		-name => 'addBidForm',
		-method => 'post',
		-action => "?auction=$auction",
	);
	
	$inner .= hidden(
		-name => 'auction',
		-value => $auction,
	).hidden(
		-name => 'addBid',
		-value => 1
	);

	$inner .= start_table({-class=>'addBid'});
	$inner .= Tr(td(
			{-colspan => 2},
			h4('Добавление ставки')
		));

	$inner .= Tr(
		td(textfield(
			-name => 'newBid',
			-size => 20,
			-value => '',
			-maxlength => 20,
		)),
		td({-class => 'change'},
			submit(
				-name => 'Добавить ставку',
			)
		)
	);
	map {$inner .= Tr(td({-colspan => 2}, Shared::error($_)))} @{$errors};

	$inner .= end_table();
	$inner .= end_form();
	return $inner;

} 

sub printTable {
	my $auction = shift;
	my $inner .= start_table({-class => 'bidsTable'});
	my $query = qq{
		SELECT u.id as userid, login, bid, datetime
			FROM bids b, users u
		WHERE auction = ? and b.user = u.id
		ORDER BY datetime DESC
	};
	my $dbh = Shared::ConnectDB();
	my $sth = $dbh->prepare($query);
	$sth->execute($auction);

	while (my $ref = $sth->fetchrow_hashref()) {
		$inner .=Tr(
			td(
				{-class=>'date datetime'},
				$ref->{datetime},
			),
			td(
				{-class=>'username'},
				a(
					{-href => "?user=$ref->{userid}"},
					$ref->{login},
				),
			),
			td(
				{-class=>'bid'},
				"$ref->{bid} $Config::currency",
			),
		);
	}
	$inner .= end_table();
	return $inner;
} 


1;
