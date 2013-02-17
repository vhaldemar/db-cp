package AddAuction;
use strict;
use warnings;
use CGI qw(:standard *table);
use Shared;
use Digest::MD5 qw(md5_hex);
use DBI;

my $fieldSize = 50;

sub get {
	my $pageParams = shift;
	my $user = $pageParams->{session} ? $pageParams->{session}->param('id') : undef;
	my $inner;
	my @errors;
	my $params;

	if ($user && defined param('addAuction')) {
		$params = checkParams(\@errors);
		if (!@errors) {
			my $id = createAuction($params, $user);
			$pageParams->{redirect} = "?auction=$id";
			return '';
		}
	}

	if ($user) {
		$inner .= printForm($pageParams, $params, \@errors);
	} else {
		$pageParams->{unauthorizedAction} = 'Вы должны зайти в систему для создания аукционов!';
	}

	return div({-id => 'addAuction'}, $inner).$\;
}

sub createAuction {
	my ($p, $user) = @_;

	my $q = qq/
		INSERT INTO auctions(
			seller, starting_price, min_step, description, start, "end", name)
		VALUES (?, ?, ?, ?, ?, ?, ?) RETURNING id;
	/;

#	$p->{description} =~ s/\[img\](.+?)\[\/img\]/<a href="$1"><img src="$1" -class="auctionImage"><\/a><br\/>/g;
	
	my $dbh = Shared::ConnectDB();
	my $sth = $dbh->prepare($q);

	$sth->execute(
		$user,
		$p->{startingPrice},
		$p->{step},
		$p->{description},
		$p->{start},
		$p->{end},
		$p->{name}
	);

	return $sth->fetchrow_hashref()->{'id'};
}

sub checkParams {
	my ($errors, $user) = @_;
	my @params = qw/name start end startingPrice step description/;
	my %r;
	foreach (@params) {
		$r{$_} = Shared::Escape(param($_)) || '';
	}

	if (keys %r < 6) {
		push @{$errors}, 'Все поля должны быть заполнены!';
	} else {
		if (Shared::IsNumber($r{startingPrice})) {
			$r{startingPrice} < $Config::minPrice
				and push @{$errors}, "Стартовая цена меньше минимальной, равной $Config::minPrice $Config::currency";
		} else {
			push @{$errors}, 'Цена должна выражаться цифрами!';
		}
		if (Shared::IsNumber($r{step})) {
			$r{step} < $Config::minStep
				and push @{$errors}, "Минимальный шаг должен быть больше, чем $Config::minStep $Config::currency";
		} else {
			push @{$errors}, 'Минимальный шаг должен выражаться цифрами!';
		}
		$r{end} <= $r{date}
			and push @{$errors}, "Дата конца аукциона должна быть больше даты начала";
	}

	while (my $image = /\[img\](.+?)\[\/img\]/) {
		if (!Shared::CheckImage($1)) {
			push @{$errors}, "По ссылке должен находиться рисунок, отвечающий требованиям: $1"
		} else {
			
		}
	}

	return \%r;
}

sub printForm { 
	my ($pageParams, $p, $errors) = @_;
	my $inner;
	my $dateTime = Shared::GetDateTime();

	$pageParams->{css}{'jquery-ui-timepicker-addon.css'} = 1;
	$pageParams->{css}{'jquery-ui-1.10.1.custom.min.css'} = 1;
	$pageParams->{javascript}{'jquery-1.9.1.min.js'} = 0;
	$pageParams->{javascript}{'jquery-ui-1.10.1.custom.min.js'} = 2;
	$pageParams->{javascript}{'jquery-ui-sliderAccess.js'} = 3;
	$pageParams->{javascript}{'jquery-ui-timepicker-addon.js'} = 4;
	$pageParams->{javascript}{'jquery-ui-timepicker-ru.js'} = 5;
	
	$inner .= start_form(
		-name => 'addAuctionForm',
		-method => 'post',
		-action => '/?addAuction',
	);
	
	$inner .= start_table({-class => 'addAuctionTable'});

	$inner .= hidden(
		-name => 'addAuction',
		-value => 'send',
	);

	$inner .= Tr(
		td('Продавец:'),
		td($pageParams->{session}->param('login')),
	);
	$inner .= Tr(
		td('Название аукциона:'),
		td(textfield(
			-name => 'name',
			-size => $fieldSize,
			-value => $p->{name} ||'',
			-maxlength => 50
		))
	);
	$inner .= Tr(
		td('Начало:'),
		td(textfield(
			-name => 'start',
			-size => 20,
			-value => $dateTime,
			-maxlength => 20,
			-readonly => 1,
		))
	);
	$inner .= Tr(
		td('Конец:'),
		td(textfield(
			-class => 'datepicker',
			-name => 'end',
			-size => 20,
			-value => $p->{end} || $dateTime,
			-maxlength => 30,
			-readonly => 1,
		))
	);
	$inner .= Tr(
		td("Стартовая цена, $Config::currency:"),
		td(textfield(
			-name => 'startingPrice',
			-size => $fieldSize,
			-value => $p->{startingPrice} || '',
			-maxlength => 30,
		))
	);
	$inner .= Tr(
		td("Минимальный шаг, $Config::currency:"),
		td(textfield(
			-name => 'step',
			-size => $fieldSize,
			-value => $p->{step} || '',
			-maxlength => 30,
		))
	);
	$inner .= Tr(
		td('Описание лота:'),
		td(textarea(
			-name => 'description',
			-default => $p->{description} || '',
		))
	);
	$inner .= Tr(
		td({-class => 'change', -colspan => 2},
			submit(
				-name => 'Создать аукцион',
			)
		),
	);

	$inner .= script( qq/
		jQuery(document).ready(function(){
			\$('.datepicker').datetimepicker({
				timeFormat: 'hh:mm:ss',
				dateFormat: 'yy-mm-dd',
				minDateTime: new Date('$dateTime')
			});
		});
	/);

	map {$inner .= Tr(td({-colspan => 2}, Shared::error($_)))} @{$errors};
	$inner .= end_table() . end_form();
	return $inner;
}


1;
