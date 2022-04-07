package Acme::Inabajun::Json::Parser;

use strict;
use warnings;
use feature 'signatures';
no warnings "experimental::signatures";
use Acme::Inabajun::Json::Lexer;

our $VERSION = '0.01';

sub parse($class, $input) {
    my $l = Acme::Inabajun::Json::Lexer->new($input);
    my $token = $l->next();
    if($token->isValue()) {

    }
}
