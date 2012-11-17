#!/usr/bin/perl -w
use strict;
use CGI::Carp 'fatalsToBrowser';
use CGI qw(:standard);

print header(-charset => 'utf-8');
print start_html(
	-lang => 'ru-RU',
	-title => 'Index',
);

my $login = 1;
require 'Header.pm' or die $!;
Header::print();

print end_html();
