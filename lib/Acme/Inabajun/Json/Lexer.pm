package Acme::Inabajun::Json::Lexer;

use strict;
use warnings;
use feature 'signatures';
no warnings "experimental::signatures";
use Acme::Inabajun::Json::Token;
use Test::More;
our $VERSION = '0.01';

# constructor. return Lexer object.
sub new ( $class, $jsonStr ) {
    return bless { ( input => $jsonStr, index => 0 ) }, $class;
}

# return next Token object.
sub next ($self) {
    $self->skip_whitespace();
    if ( length $self->{input} <= $self->{index} ) {
        return Acme::Inabajun::Json::Token->eof();
    }
    my $i = $self->now();
    $self->{index}++;
    return Acme::Inabajun::Json::Token->l_paren()   if ( $i eq '{' );
    return Acme::Inabajun::Json::Token->r_paren()   if ( $i eq '}' );
    return Acme::Inabajun::Json::Token->l_bracket() if ( $i eq '[' );
    return Acme::Inabajun::Json::Token->r_bracket() if ( $i eq ']' );
    return Acme::Inabajun::Json::Token->colon()     if ( $i eq ':' );
    return Acme::Inabajun::Json::Token->comma()     if ( $i eq ',' );

    if ( $i eq '"' ) {
        my $str = $self->parseString();
        return Acme::Inabajun::Json::Token->string($str);
    }
    if ( $i =~ /[-0-9]/ ) {
        $self->{index}--;
        my $number = $self->parseNumber();
        return Acme::Inabajun::Json::Token->number($number);
    }

    $self->{index}--;
    return $self->parseKeyword();
}

sub skip_whitespace ($self) {
    while ( $self->now() =~ /\s/ ) {
        $self->{index}++;
    }
}

sub parseString ($self) {
    my $start = $self->{index};
    while ( !( $self->now() eq '"' ) ) {
        if ( length $self->{input} <= $self->{index} ) {
            die 'find only single double quote';
        }
        $self->{index}++ if $self->now() eq '\\';
        $self->{index}++;
    }
    my $len = $self->{index} - $start;
    $self->{index}++;
    return substr $self->{input}, $start, $len;
}

sub parseNumber ($self) {
    my $start = $self->{index};
    my $after = substr( $self->{input}, $self->{index} );
    $after =~ /-?(0|([1-9][0-9]*))\.?[0-9]*([eE][+-][0-9]+)?/;
    $self->{index} = $start + $+[0];
    return substr $self->{input}, $start, $+[0];
}

# true or false or null
sub parseKeyword ($self) {
    my $start = $self->{index};
    my $after = substr( $self->{input}, $self->{index} );
    if ($after =~ /(true|false|null)/) {
      $self->{index} = $start + $+[0];
      return Acme::Inabajun::Json::Token->keyword(substr $self->{input}, $start, $+[0]);
    }
}

sub now ($self) {
    return substr( $self->{input}, $self->{index}, 1 );
}
