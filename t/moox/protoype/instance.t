package main;

use Test::More;

my $class;
use_ok $class = 'MooX::Prototype::Instance';
can_ok $class, qw(package);

ok !$class->can('new'), 'class has no constructor';

my $instance = bless {}, $class;
my $package  = $instance->package;

isa_ok $package, 'MooX::Prototype::Package';
can_ok $package, qw(name before after around install include);

ok 1 and done_testing;
