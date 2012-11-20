#!/usr/bin/perl -w
use strict;
use CGI::Carp 'fatalsToBrowser';
use CGI qw(:standard);
use config;
use modules;

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

# Start html
	print header(-charset => 'utf-8');
	print start_html(
		-lang => 'ru-RU',
		-title => 'Index',
		-style => {'src' => 'base.css'},
	);
	
	my ($wrapper, $middle);
	$middle .= div(
		{-id => 'container'},
		getContent(),
	);
	$middle .= Menu::get();

	$wrapper .= Header::get();
	$wrapper .= div({-id => 'middle'}, $middle);

	print div({-id => 'wrapper'}, $wrapper);
	
	Footer::print();
	
	print end_html();
}

sub getContent {
	my $isLogin = shift;
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
		}
	}

	return Modules::getPage($page);
}

