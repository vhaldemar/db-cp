package UnauthorizedAction;
use strict;
use warnings;
use CGI qw(:standard);

sub get {
	my $pageParams = shift;
	my $message = $pageParams->{unauthorizedAction};
	my $inner .= p(
		'Вы совершили несанкционированное дейстие. Это означает, что вам необходимо зайти в систему либо что вам не хватает прав на совершение данного действия.',
	);
	if ($message) {
		$inner .= 'Причина запрета доступа: '.$message;
	}

	return div({-id => 'unauthorized_action'}, $inner).$\;
}


1;
