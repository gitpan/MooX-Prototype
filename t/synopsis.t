use Test::More;
use Scalar::Util qw(refaddr);

use MooX::Prototype;

my $bear = object
    name     => 'bear',
    type     => 'black bear',
    attitude => 'indifferent',
    responds => sub { 'Roarrrr' },
    begets   => sub { shift->isa(ref shift) }
;

my $papa = extend $bear,
    name     => 'papa bear',
    type     => 'great big papa bear',
    attitude => 'agitated',
    responds => sub { "Who's been eating my porridge?" },
;

my $baby = extend $papa,
    name     => 'baby bear',
    type     => 'tiny little baby bear',
    responds => sub { "Who's eaten up all my porridge?" },
;

my $mama = extend $bear,
    name     => 'mama bear',
    type     => 'middle-sized mama bear',
    attitude => 'confused',
    responds => sub { "Who's been eating my porridge?" },
;

my $statement = 'The %s said, "%s"';
ok $papa && $mama && $baby && $baby->begets($papa);

is ((sprintf $statement, $papa->name, $papa->responds),
    qq(The papa bear said, "Who's been eating my porridge?"));
is ((sprintf $statement, $mama->name, $mama->responds),
    qq(The mama bear said, "Who's been eating my porridge?"));
is ((sprintf $statement, $baby->name, $baby->responds),
    qq(The baby bear said, "Who's eaten up all my porridge?"));

isnt refaddr($bear), refaddr($papa);
isnt refaddr($baby), refaddr($papa);
isnt refaddr($baby), refaddr($bear);
isnt refaddr($mama), refaddr($bear);

ok 1 and done_testing;
