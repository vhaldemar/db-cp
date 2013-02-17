package DeleteWarranty;
use strict;
use warnings;
use CGI qw(:standard *table);
use Shared;

sub get {
	my $pageParams = shift;
	my $id = Shared::Escape(param('deleteWarranty')) || '';
	my $thisUser = $pageParams->{session} ? $pageParams->{session}->param('id') : '';
	my $inner;

	if (!$thisUser) {
		$pageParams->{unauthorizedAction} = 'Вы должны зайти в систему для выполнения данного действия!';
	} else {
		my $query = qq{
			SELECT guarantor, "user"
				FROM guarantee
			WHERE id = ?
		};
		
		my $dbh = Shared::ConnectDB();
		my $sth = $dbh->prepare($query);
		$sth->execute($id);
		my $ref = $sth->fetchrow_hashref();

		if (!$ref) {
			$pageParams->{unauthorizedAction} = 'Такого поручительства не существует!';
		} elsif ($ref->{guarantor} ne $thisUser and $ref->{user} ne $thisUser) {
			$pageParams->{unauthorizedAction} = 'Вы не можете удалить чужое поручительство!';
		} else {
			my $user = $ref->{user};
			$query = qq{
				DELETE FROM guarantee
				WHERE id = ?
			};
			$sth = $dbh->prepare($query);
			$sth->execute($id);
			$pageParams->{redirect} = "?user=$user";
		}
	}

	return div({-id => 'addWarranty'}, $inner).$\;
}

1;
