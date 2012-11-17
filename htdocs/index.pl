#!/usr/bin/perl -w
use strict;
use CGI::Carp 'fatalsToBrowser';
use CGI qw(:standard);
use ModPerl::Util;
use config;

$\ ||= '';

my %modules = (
	'Module/Main.pm' => 'Main',
	'Module/Auth.pm' => 'Auth',
);

my %pages = (
	main => ['Module/Main.pm'],
	auth => ['Module/Auth.pm'],
);

# Call the install script
if (-e $Config::root.'/install.pl') {
	require 'install.pl';
	exit;
	ModPerl::Util::exit();
}

# Start html
print header(-charset => 'utf-8');
print start_html(
	-lang => 'ru-RU',
	-title => 'Index',
);

my $isLogin = 0;

my $wrapper;
require 'Module/Header.pm' or die $!;
require 'Module/Menu.pm' or die $!;
require 'Module/Footer.pm' or die $!;
$wrapper .= Header::get($isLogin);
$wrapper .= Menu::get($isLogin);
$wrapper .= Footer::get($isLogin);

$wrapper .= div({-id => 'content'}, getContent());
print div({-id => 'wrapper'}, $wrapper);

sub getContent {
	my @params = param();
	my $page = 'main';
	my $content;

	foreach (@params) {
		if ($_ eq 'keywords') {
			my @keywords = param($_);
			@keywords == 1
				or next;
			
			$pages{$keywords[0]}
				and $page = $keywords[0];
			last;
		} elsif ($pages{$_}) {
			$page = $_;
			last;
		}
	}

	foreach(@{ $pages{$page} }) {
		require $_ or die $!;
		$content .= eval($modules{$_}."::get($isLogin)");
	}

	return $content;
}

print end_html();
