package Acme::Inabajun::Json::Token;

use strict;
use warnings;
use feature 'signatures';
no warnings "experimental::signatures";

our $VERSION = '0.01';

sub eof ($class) {
    return bless { ( type => 'EOF' ) }, $class;
}

sub l_paren ($class) {
    return bless { ( type => 'LPAREN' ) }, $class;
}

sub r_paren ($class) {
    return bless { ( type => 'RPAREN' ) }, $class;
}

sub l_bracket ($class) {
    return bless { ( type => 'LBRACKET' ) }, $class;
}

sub r_bracket ($class) {
    return bless { ( type => 'RBRACKET' ) }, $class;
}

sub comma ($class) {
    return bless { ( type => 'COMMA' ) }, $class;
}

sub colon ($class) {
    return bless { ( type => 'COLON' ) }, $class;
}

sub string ( $class, $value ) {
    return bless { ( type => 'STRING' ), value => $value }, $class;
}

sub number ( $class, $value ) {
    return bless { ( type => 'NUMBER' ), value => $value }, $class;
}

sub keyword ($class, $value) {
    return bless { ( type => 'KEYWORD' ), value => $value }, $class;
}

sub isValue ($self) {
    my $type = $self->{type};
    if ($type eq 'KEYWORD' || $type eq 'NUMBER' || $type eq 'STRING') {
        return 1;
    }
    return 0;
}

sub getValue ($self) {
    if($self->{type} eq 'KEYWORD') {
        if($self->{value} eq 'true') {
            return 1;
        }
        if($self->{value} eq 'false') {
            return 0;
        }
        if($self->{value} eq 'null') {
            return undef;
        }
    }
    return $self->{value};
}
