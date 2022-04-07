#!perl
use 5.006;
use strict;
use warnings;
use Test::More;
use Acme::Inabajun::Json::Parser;
use Data::Dumper;
plan tests => 3;

subtest 'single value' => sub {
    is( Acme::Inabajun::Json::Parser->parse('10'), 10, 'single number' );
    is( Acme::Inabajun::Json::Parser->parse('"string"'),
        'string', 'single string' );
    is( Acme::Inabajun::Json::Parser->parse('null'),  undef, 'null' );
    is( Acme::Inabajun::Json::Parser->parse('true'),  1,     'true' );
    is( Acme::Inabajun::Json::Parser->parse('false'), 0,     'false' );
};

subtest 'array' => sub {

    subtest 'no value array' => sub {
        my $result = Acme::Inabajun::Json::Parser->parse('[]');
        my $len    = @{$result};
        is( $len, 0 );
    };

    subtest 'single value array' => sub {
        my @result = @{ Acme::Inabajun::Json::Parser->parse('[1]') };
        is( $result[0], 1, '@result[0] is 1' );
        my $len = @result;
        is( $len, 1 );
    };

    subtest 'multiple value array' => sub {
        my @result = @{ Acme::Inabajun::Json::Parser->parse('[1,2,3,4]') };
        is( $result[0], 1, '@result[0] is 1' );
        is( $result[1], 2, '@result[1] is 2' );
        is( $result[2], 3, '@result[2] is 3' );
        is( $result[3], 4, '@result[3] is 4' );
        my $len = @result;
        is( $len, 4 );
    };

    subtest 'nested array' => sub {
        my @result = @{ Acme::Inabajun::Json::Parser->parse('[[1,2],[3,4]]') };
        is( $result[0]->[0], 1, '$result[0]->[0] is 1' );
        is( $result[0]->[1], 2, '$result[0]->[1] is 2' );
        my $len1 = @{ $result[0] };
        is( $len1,           2 );
        is( $result[1]->[0], 3, '$result[1]->[0] is 3' );
        is( $result[1]->[1], 4, '$result[1]->[1] is 4' );
        my $len2 = @{ $result[1] };
        is( $len2, 2 );

        # whole array length
        my $len3 = @result;
        is( $len3, 2 );
    };
};

subtest 'object' => sub {

    subtest 'no value object' => sub {
        my $result = Acme::Inabajun::Json::Parser->parse('{}');
        my $len    = keys %{$result};
        is( $len, 0 );
    };
    subtest 'single key value object' => sub {
        my %result =
          %{ Acme::Inabajun::Json::Parser->parse('{"key":"value"}') };
        is( $result{key}, 'value', '{"key":"value"}{key} is "value"' );
        my $len = keys %result;
        is( $len, 1 );
    };
    subtest 'multiple key value object' => sub {
        my %result = %{ Acme::Inabajun::Json::Parser->parse(
                '{"key1":"value1", "key2":"value2"}')
        };
        is( $result{key1}, 'value1',
            '{"key1":"value1", "key2":"value2"}{key1} is "value1"' );
        is( $result{key2}, 'value2',
            '{"key1":"value1", "key2":"value2"}{key2} is "value2"' );
        my $len = keys %result;
        is( $len, 2 );
    };
    subtest 'nested object' => sub {
        my %result = %{ Acme::Inabajun::Json::Parser->parse( '
        {
            "key1":"value1",
            "key2":"value2",
            "key3":{
                "ckey1":"cvalue1",
                 "ckey2":"cvalue2"
                 },
            "key4":[1,2,3]
         }' )
        };
        is( $result{key1},          'value1',  'parent key1 is "value1"' );
        is( $result{key2},          'value2',  'parent key2 is "value2"' );
        is( $result{key3}->{ckey1}, 'cvalue1', 'key3->ckey1 is "cvalue1"' );
        is( $result{key3}->{ckey2}, 'cvalue2', 'key3->ckey2 is "cvalue2"' );
        is( $result{key4}->[0],     1,         'parent key4[0] is value 1' );
        is( $result{key4}->[1],     2,         'parent key4[1] is value 2' );
        is( $result{key4}->[2],     3,         'parent key4[2] is value 3' );

        # parent object length
        my $len1 = keys %result;
        is( $len1, 4 );

        # child object length
        my $len2 = keys %{ %result{key3} };
        is( $len2, 2 );

        # child array length
        my $len3 = @{ %result{key4} };
        is( $len3, 3 );

    };

};
