use Test::More;
use Scalar::Util qw(blessed refaddr);

use MooX::Prototype;

my $user = object name => undef;
can_ok $user, 'name', 'package';
ok blessed $user;

my $employee = extend $user => (
    job      => 'janitor',
    employer => 'Government',
);
isnt refaddr($employee), refaddr($user);
isa_ok $employee, ref $user;
can_ok $employee, 'name', 'package', 'job', 'employer';
ok blessed $employee;

my $officer = extend $employee => (
    job => 'officer',
);
isnt refaddr($officer), refaddr($employee);
isa_ok $officer, ref $employee;
can_ok $officer, 'name', 'package', 'job', 'employer';
ok blessed $officer;
is $officer->name, undef;
is $officer->job, 'officer';
is $officer->employer, 'Government';

my $captain1 = extend $officer => (
    job => 'captain',
    officers => [9,8,7],
);
isa_ok $captain1, ref $officer;
can_ok $captain1, 'name', 'package', 'job', 'employer', 'officers';
ok blessed $captain1;
is $captain1->name, undef;
is $captain1->job, 'captain';
is $captain1->employer, 'Government';
is_deeply $captain1->officers, [9,8,7];
$captain1->officers->[0] = undef;
is_deeply $captain1->officers, [undef,8,7];

my $captain2 = extend $captain1;
isa_ok $captain2, ref $captain1;
can_ok $captain2, 'name', 'package', 'job', 'employer', 'officers';
ok blessed $captain2;
is $captain1->name, undef;
is $captain1->job, 'captain';
is $captain1->employer, 'Government';
is_deeply $captain2->officers, [undef,8,7];
$captain2->officers->[0] = 9;
is_deeply $captain2->officers, [9,8,7];
is_deeply $captain1->officers, [undef,8,7];

ok 1 and done_testing;
