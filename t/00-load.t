#!perl
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Acme::Inabajun::Json::Parser' ) || print "Bail out!\n";
}

diag( "Testing Acme::Inabajun::Json::Parser $Acme::Inabajun::Json::Parser::VERSION, Perl $], $^X" );
