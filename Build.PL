use 5.006;
use strict;
use warnings;
use Module::Build;
Module::Build->VERSION('0.4004');

my $builder = Module::Build->new(
    module_name         => 'Acme::Inabajun::Json::Parser',
    license             => 'artistic_2',
    dist_author         => q{inabajunmr <inabajun.for.regi@gmail.com>},
    dist_version_from   => 'lib/Acme/Inabajun/Json/Parser.pm',
    release_status      => 'stable',
    configure_requires => {
        'Module::Build' => '0.4004',
    },
    test_requires => {
        'Test::More' => '0',
    },
    requires => {
        #'ABC'              => '1.6',
        #'Foo::Bar::Module' => '5.0401',
    },
    add_to_cleanup     => [ '.-*' ],
);

$builder->create_build_script();
