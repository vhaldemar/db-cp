#!/usr/bin/perl -w
use strict;
use utf8;
binmode STDOUT, ":utf8";
use CGI qw(:standart);
use CGI::Carp 'fatalsToBrowser';

# CONFIG SECTION
my $siteName = "dbcp";
my $documentsRoot = "home/vhaldemar/git/db-cp/htdocs/";

#END OF CONFIG SECTION

use lib "/home/vhaldemar/git/db-cp/htdocs/";

1;
