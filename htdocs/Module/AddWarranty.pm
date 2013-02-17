package AddWarranty;
use strict;
use warnings;
use CGI qw(:standard *table);
use Shared;
require 'Module/Events.pm';

sub get {
	my $pageParams = shift;
	my $user = Shared::Escape(param('userId')) || '';
	my $text = Shared::Escape(param('warrantyText')) || '';
	my $thisUser = $pageParams->{session} ? $pageParams->{session}->param('id') : '';
	my $myPage = $thisUser eq $user ? 1 : 0;
	my $inner;

	if (!$text) {
		$pageParams->{unauthorizedAction} = 'Текст поручительства не может быть пустым!';
	} elsif (!$user) {
		$pageParams->{unauthorizedAction} = 'Не указан пользователь';
	} elsif (!$thisUser) {
		$pageParams->{unauthorizedAction} = 'Вы должны зайти в систему для выполнения данного действия!';
	} elsif ($user eq $thisUser) {
		$pageParams->{unauthorizedAction} = 'Нельзя добавлять поручительства себе!';
	} else {
		my $query = qq{
			SELECT count(*)
				FROM guarantee
			WHERE guarantor = ? and "user" = ?
		};
		
		my $dbh = Shared::ConnectDB();
		my $sth = $dbh->prepare($query);
		$sth->execute($thisUser, $user);
		
		if ($sth->fetchrow_hashref()->{count} != 0) {
			$pageParams->{unauthorizedAction} = 'Вы уже добавили поручительство для этого пользователя!';
		} else {
			my $name = $pageParams->{session}->param('login');
			$query = qq{
				INSERT INTO guarantee(
					guarantor, "user", text, date)
			    VALUES (?, ?, ?, ?);
			};
			$sth = $dbh->prepare($query);
			$sth->execute($thisUser, $user, $text, Shared::GetDate());
			$pageParams->{redirect} = "?user=$user";
			Events::addEvent(
				$user,
				3,
				"Пользователь ".a({-href=>"?user=$thisUser"}, $name)." добавил вам поручительство."
			);
		}
	}

	return div({-id => 'addWarranty'}, $inner).$\;
}

1;
