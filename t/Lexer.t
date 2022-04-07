#!perl
use 5.006;
use strict;
use warnings;
use Test::More;
use Test::Exception;
use Acme::Inabajun::Json::Lexer;
use Data::Dumper;

subtest 'new' => sub {
    my $l = Acme::Inabajun::Json::Lexer->new('abc');
    is( $l->{input}, 'abc', 'same input as argument' );
    is( $l->{index}, 0,     'innitial index is 0' );

    dies_ok {
        Acme::Inabajun::Json::Lexer->new();
    }
    'no arguments';
    dies_ok {
        Acme::Inabajun::Json::Lexer->new( 'abc', 'abc' );
    }
    'too much arguments';
};

subtest 'next' => sub {
    subtest 'meta tokens' => sub {
        subtest '{}():,' => sub {
            my $l = Acme::Inabajun::Json::Lexer->new('{}():,');
            is( $l->next()->{type}, 'LPAREN',   'first token is {' );
            is( $l->{index},        1,          'index incremented to 1' );
            is( $l->next()->{type}, 'RPAREN',   'second token is }' );
            is( $l->{index},        2,          'index incremented to 2' );
            is( $l->next()->{type}, 'LBRACKET', 'third token is (' );
            is( $l->{index},        3,          'index incremented to 3' );
            is( $l->next()->{type}, 'RBRACKET', 'third token is )' );
            is( $l->{index},        4,          'index incremented to 4' );
            is( $l->next()->{type}, 'COLON',    'third token is :' );
            is( $l->{index},        5,          'index incremented to 5' );
            is( $l->next()->{type}, 'COMMA',    'third token is ,' );
            is( $l->{index},        6,          'index incremented to 6' );
            is( $l->next()->{type}, 'EOF',
                'this string has only 3 charactors' );
        };
        subtest "  {  }  \n ( \t)  " => sub {
            my $l = Acme::Inabajun::Json::Lexer->new("  {  }  \n ( \t)  ");
            is( $l->next()->{type}, 'LPAREN',   '1:{' );
            is( $l->next()->{type}, 'RPAREN',   '2:}' );
            is( $l->next()->{type}, 'LBRACKET', '3:(' );
            is( $l->next()->{type}, 'RBRACKET', '4:)' );
            is( $l->next()->{type}, 'EOF',      '5:EOF' );
        };
      };
      subtest 'String' => sub {
        subtest '"text"' => sub {
            my $l   = Acme::Inabajun::Json::Lexer->new('"text"');
            my $str = $l->next();
            is( $str->{type},  'STRING',   '1:type is String' );
            is( $str->{value}, 'text',     '1:value is text' );
            is( $l->{index},   6,          'index is 6 after reading string' );
            is( $l->next()->{type}, 'EOF', '2:EOF' );
        };
        subtest '"te xt"' => sub {
            my $l   = Acme::Inabajun::Json::Lexer->new('"te xt"');
            my $str = $l->next();
            is( $str->{type},       'STRING', '1:type is String' );
            is( $str->{value},      'te xt',  '1:value is te xt' );
            is( $l->next()->{type}, 'EOF',    '2:EOF' );
        };
        subtest '"te\"xt"' => sub {
            my $l   = Acme::Inabajun::Json::Lexer->new('"te\"xt"');
            my $str = $l->next();
            is( $str->{type},       'STRING', '1:type is String' );
            is( $str->{value},      'te\"xt', '1:value is te\"xt' );
            is( $l->next()->{type}, 'EOF',    '2:EOF' );
        };
    };
    subtest 'Number' => sub {
        subtest 'in:10' => sub {
            my $l   = Acme::Inabajun::Json::Lexer->new('10');
            my $num = $l->next();
            is( $num->{type},       'NUMBER', '1:type is NUMBER' );
            is( $num->{value},      '10', '1:value is 10' );
            is( $l->next()->{type}, 'EOF',    '2:EOF' );
        };
        subtest 'in:-123'  => sub {
            my $l   = Acme::Inabajun::Json::Lexer->new('-123');
            my $num = $l->next();
            is( $num->{type},       'NUMBER', '1:type is NUMBER' );
            is( $num->{value},      '-123', '1:value is -123' );
            is( $l->next()->{type}, 'EOF',    '2:EOF' );
        };
        subtest 'in:-0.123'  => sub {
            my $l   = Acme::Inabajun::Json::Lexer->new('-0.123');
            my $num = $l->next();
            is( $num->{type},       'NUMBER', '1:type is NUMBER' );
            is( $num->{value},      '-0.123', '1:value is -0.123' );
            is( $l->next()->{type}, 'EOF',    '2:EOF' );
        };
        subtest 'in:-0.123E+2'  => sub {
            my $l   = Acme::Inabajun::Json::Lexer->new('-0.123E+2');
            my $str = $l->next();
            is( $str->{type},       'NUMBER', '1:type is NUMBER' );
            is( $str->{value},      '-0.123E+2', '1:value is -0.123E+2' );
            is( $l->next()->{type}, 'EOF',    '2:EOF' );
        };
        subtest 'in:-0.123E+2 10e-4'  => sub {
            my $l   = Acme::Inabajun::Json::Lexer->new('-0.123E+2 10e-4');
            my $num1 = $l->next();
            is( $num1->{type},       'NUMBER', '1:type is NUMBER' );
            is( $num1->{value},      '-0.123E+2', '1:value is -0.123E+2' );
            my $num2 = $l->next();
            is( $num2->{type},       'NUMBER', '2:type is NUMBER' );
            is( $num2->{value},      '10e-4', '2:value is 10e-4' );
            is( $l->next()->{type}, 'EOF',    '3:EOF' );
        };        
    };
    subtest 'true/false/null' => sub {
            my $l   = Acme::Inabajun::Json::Lexer->new(' true false null ');
            my $num1 = $l->next();
            is( $num1->{type},       'KEYWORD', '1:type is KEYWORD' );
            is( $num1->{value},      'true', '1:value is true' );
            my $num2 = $l->next();
            is( $num2->{type},       'KEYWORD', '2:type is KEYWORD' );
            is( $num2->{value},      'false', '2:value is false' );
            my $num3 = $l->next();
            is( $num3->{type},       'KEYWORD', '3:type is KEYWORD' );
            is( $num3->{value},      'null', '3:value is null' );
    };

};

done_testing();
