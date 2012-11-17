#!/usr/bin/perl -w
use strict;
use CGI::Carp 'fatalsToBrowser';
use CGI qw(:standard);
$\ ||= '';

print header(-charset => 'utf-8');
print start_html(
	-lang => 'ru-RU',
	-title => 'Index',
);


my $isLogin = 1;

my $wrapper;

require 'Module/Header.pm' or die $!;
require 'Module/Menu.pm' or die $!;
require 'Module/Footer.pm' or die $!;
$wrapper .= Header::get($isLogin);
$wrapper .= Menu::get($isLogin);
$wrapper .= Footer::get($isLogin);

require 'Module/Main.pm' or die $!;
my $content;

$content .= Main::get($isLogin);
$wrapper .= div({-id => 'content'}, $content);
print div({-id => 'wrapper'}, $wrapper);



print end_html();
