package Acme::Inabajun::Json::Parser;

use strict;
use warnings;
use feature 'signatures';
no warnings "experimental::signatures";
use Acme::Inabajun::Json::Lexer;
our $VERSION = '0.01';

sub parse ( $class, $input ) {
    my $l = Acme::Inabajun::Json::Lexer->new($input);
    return innerParse($l);
}

sub innerParse ($lexer) {
    my $token = $lexer->next();
    if ( $token->isValue() ) {
        return $token->getValue();
    }
    if (   $token->{type} eq 'RBRACKET'
        || $token->{type} eq 'RPAREN'
        || $token->{type} eq 'COMMA' )
    {
        return $token;
    }
    if ( $token->{type} eq 'LBRACKET' ) {
        return parseArray($lexer);
    }
    if ( $token->{type} eq 'LPAREN' ) {
        return parseObject($lexer);
    }
}

# return array reference
sub parseArray ($lexer) {
    my $next   = innerParse($lexer);
    my @result = ();
    if ( !( ref($next) eq 'Acme::Inabajun::Json::Token' ) ) {
        push( @result, $next );
    }
    while (1) {
        if ( ref($next) eq 'Acme::Inabajun::Json::Token' ) {
            if ( $next->{type} eq 'RBRACKET' ) {
                return \@result;
            }
            elsif ( $next->{type} eq 'COMMA' ) {
                $next = innerParse($lexer);
                push( @result, $next );
            }
            elsif ( $next->{type} eq 'EOF' ) {
                die 'unclosed array';
            }
        }
        else {
            $next = $lexer->next();
        }
    }
}

# return hash reference
sub parseObject ($lexer) {

    my %result = ();
    while (1) {

        my $key = $lexer->next();
        if ( $key->{type} eq "RPAREN" ) {
            return \%result;
        }
        if ( !$key->{type} eq "STRING" ) {
            die 'object needs key';
        }
        my $colon = $lexer->next();
        if ( !$colon->{type} eq "COLON" ) {
            die 'object needs colon';
        }
        my $value = innerParse($lexer);
        $result{ $key->getValue() } = $value;
        my $next = $lexer->next();

        if ( ref($next) eq 'Acme::Inabajun::Json::Token' ) {
            if ( $next->{type} eq 'RPAREN' ) {
                return \%result;
            }
            elsif ( $next->{type} eq '{COMMA}' ) {
                next;
            }
            elsif ( $next->{type} eq 'EOF' ) {
                die 'unclosed object';
            }
        }
    }
}
