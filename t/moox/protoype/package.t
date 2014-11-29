package Test::MooX::Prototype::Package;

use Moo;

sub test_method1 {
    0
}

sub test_method2 {
    0
}

sub test_method3 {
    12345
}

package Test::MooX::Prototype::Package::Plus;

use Moo;

sub test_method5 {
    987654321
}

package Test::MooX::Prototype::Package::Options;

use Moo::Role;

has 'true'  => (is => 'ro', default => 1);
has 'false' => (is => 'ro', default => 0);

package main;

use Test::More;

my $class;
use_ok $class = 'MooX::Prototype::Package';
can_ok $class, qw(name before after around install include);

my $package = $class->new(name => 'Test::MooX::Prototype::Package');
is $package->name, 'Test::MooX::Prototype::Package';

my $after  = 0;
my $before = 0;
my $around = 0;

$package->after(test_method1 => sub {
    $after++;
});

$package->before(test_method2 => sub {
    $before++;
});

$package->around(test_method3 => sub {
    my ($orig, $self, @args) = @_;
    ++$around and return $self->$orig(@args) . 6789;
});

my $tester = Test::MooX::Prototype::Package->new;
can_ok $tester, qw(new test_method1 test_method2 test_method3);
isa_ok $tester, 'Test::MooX::Prototype::Package', 'test class instantiated';

ok !$after, 'test_method1 after hook NOT invoked yet';
is $tester->test_method1, 0, 'test_method1 method returns expected data';
ok $after, 'test_method1 after hook invoked';

ok !$before, 'test_method2 before hook NOT invoked yet';
is $tester->test_method2, 0, 'test_method2 method returns expected data';
ok $before, 'test_method2 before hook invoked';

ok !$around, 'test_method3 around hook NOT invoked yet';
is $tester->test_method3, 123456789, 'test_method3 method returns expected data';
ok $around, 'test_method3 around hook invoked';

ok !$tester->can('test_method4'), 'test class has no test_method4 method';
$package->install(test_method4 => sub { 'zzz' });
ok $tester->can('test_method4'), 'test class now has a test_method4 method';
is $tester->test_method4, 'zzz', 'test_method4 method returns expected data';

ok !$tester->can('test_method5'), 'test class has no test_method5 method';
$package->include(class => 'Test::MooX::Prototype::Package::Plus');
ok $tester->can('test_method5'), 'test class now has a test_method5 method';
is $tester->test_method5, 987654321, 'test_method5 method returns expected data';

ok !$tester->can('true'), 'test class has no true method';
ok !$tester->can('false'), 'test class has no false method';
$package->include(role => 'Test::MooX::Prototype::Package::Options');
ok $tester->DOES('Test::MooX::Prototype::Package::Options');
ok $tester->can('true'), 'test class now has a true method';
ok $tester->can('false'), 'test class now has a false method';
is $tester->true, undef, 'true method returns expected data';
is $tester->false, undef, 'false method returns expected data';

ok 1 and done_testing;
