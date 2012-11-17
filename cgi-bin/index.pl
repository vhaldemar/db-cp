#!/usr/bin/perl -w
use strict;

use CGI qw(:standart);
use CGI::Carp 'fatalsToBrowser';

my $q = CGI->new();
print $q->header();
print "hello!";

