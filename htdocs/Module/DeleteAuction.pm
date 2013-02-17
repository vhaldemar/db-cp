package DeleteAuction;
use strict;
use warnings;
use CGI qw(:standard);
use Shared;

sub get {
	my $pageParams = shift;
	my $auction = Shared::Escape(param('deleteAuction')) || '';
	my $user = $pageParams->{session} ? $pageParams->{session}->param('id') : '';
	my $inner;

	if ($auction) {
		my $query = qq{
			SELECT seller,
				(SELECT count(*) FROM bids b WHERE b.auction = a.id )count
				FROM auctions a
			WHERE a.id = ?
		};

		my $dbh = Shared::ConnectDB();
		my $sth = $dbh->prepare($query);
		$sth->execute($auction);
		my $ref = $sth->fetchrow_hashref();
	
		if (!$ref) {
			$pageParams->{unauthorizedAction} = 'Такого аукциона не существует!';
		} elsif ($ref->{seller} ne $user) {
			$pageParams->{unauthorizedAction} = 'Нельзя удалять чужие аукционы!';
		} elsif ($ref->{count} ne '0') {
			$pageParams->{unauthorizedAction} = 'Нельзя удалять аукционы со ставками!';
		} else {
			$query = qq{
				DELETE FROM auctions
				WHERE id = ?;
			};
			$sth = $dbh->prepare($query);
			$sth->execute($auction);
			$pageParams->{redirect} = "?myAuctions";
		}
	} else {
		$pageParams->{unauthorizedAction} = 'Не указан аукцион';
	}

	return div({-id => 'user'}, $inner).$\;
}


1;
