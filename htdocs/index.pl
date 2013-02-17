#!/usr/bin/perl -w
use strict;
use CGI qw(:standard);
use config;
use modules;
use Shared;

local $\ ||= "\n";

# Call the install script
if (-e $Config::root.'/install.pl') {
	local $\ = "\n";
	print "Status: 301 Moved Permanently";
	print "Location: /install.pl?step=1\n";
} else {
	require 'Module/Header.pm' or die $!;
	require 'Module/Menu.pm' or die $!;
	require 'Module/Footer.pm' or die $!;

	my $content;
	my %pageParams = %Config::defPageParams;
	$pageParams{session} = Shared::getSession();

	if (
		$pageParams{session}
			&& $pageParams{session}->is_expired()
	) {
		$pageParams{redirect} = '?auth&expired=1';
		require 'Module/Logout.pm' or die $!;
		Logout::killSession(\%pageParams);
	} else {
		$content = getContent(\%pageParams);
	}

	printPage($content, \%pageParams);
}

sub printPage {
	my $content = shift;
	my $pageParams = shift;

	if (my $dest = $pageParams->{redirect}) {
		local $\ = "\n";
		print "Status: 302 Moved";
		print "Location: $dest\n";
	} elsif (my $header = $pageParams->{header}) {
		print $header;
	} else {
		print header(-charset => 'utf-8');
		print start_html(
			-lang => 'ru-RU',
			-title => 'Index',
			%{ pageParamsToCGIFormat($pageParams) },
		);
		
		my ($wrapper, $middle);
		$middle .= div(
			{-id => 'container'},
			$content,
		);
		$middle .= Menu::get($pageParams);
		$wrapper .= Header::get($pageParams);
		$wrapper .= div({-id => 'middle'}, $middle);
		print div({-id => 'wrapper'}, $wrapper);
		Footer::print();
		print end_html();
	}
}

sub getContent {
	my $pageParams = shift;
	my @params = param();
	my $page = 'main';
	my $content;

	foreach (@params) {
		if ($_ eq 'keywords') {
			my @keywords = param($_);
			@keywords == 1
				or next;
			Modules::isPage($keywords[0])
				and $page = $keywords[0];
			last;
		} elsif (Modules::isPage($_)) {
			$page = $_;
			last;
		} elsif ($_ eq 'print_params') {
			$content .= join (', ', @params);
		}
	}
	$pageParams->{page} = $page;
	$content .= Modules::getPage($page, $pageParams);
}

sub pageParamsToCGIFormat {
	my $pageParams = shift;
	my %result;
	my @scripts;

	while (my $src = each %{ $pageParams->{css} }) {
		push @{ $result{'-style'} }, {-src => "css/$src"};
	}

	
	while (my ($src, $p) = each %{ $pageParams->{javascript} }) {
		push @scripts, {-type=>"text/javascript", -src => "js/$src", -p => $p};
	}

	@scripts = sort {$a->{'-p'} <=> $b->{'-p'}} @scripts;

	foreach (@scripts) {
		delete $_->{-p};
		push @{ $result{'-script'} }, $_;
	}
	return \%result;
}
