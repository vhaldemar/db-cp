#!/usr/bin/perl -w
use strict;
use utf8;
binmode STDOUT, ":utf8";
use CGI qw(:standart);
use CGI::Carp 'fatalsToBrowser';

$\ = "\n";

use lib "/home/vhaldemar/git/db-cp/htdocs";
use config;

1;
