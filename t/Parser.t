#!perl
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 3;

{
    is($Perser->new('{ "key" : "value" }')->get('key')->asString(), 'value')
}
