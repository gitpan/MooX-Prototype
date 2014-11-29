use Test::More;

no warnings 'once';

my $class;
use_ok $class = 'MooX::Prototype';
can_ok $class, qw(import build_args build_attribute build_class build_clone);
can_ok $class, qw(build_method build_properties build_object);
ok !$class->can('new'), 'class has no constructor';

*build_args = *MooX::Prototype::build_args;

my $hash1 = {1,2,3,{4,5,6,{7,8}}};
my $hash2 = {0,1,2,{3,4,5,{6,7}}};
my $hash3 = build_args($hash1, $hash2);
my $hash4 = build_args($hash2, $hash1);

is_deeply {1,2,3,{4,5,6,{7,8}}}, $hash1, 'data compares';
is_deeply {0,1,2,{3,4,5,{6,7}}}, $hash2, 'data compares';
is_deeply {0,1,1,2,2,{3,4,5,{6,7}},3,{4,5,6,{7,8}}}, $hash3, 'data compares';
is_deeply {0,1,1,2,2,{3,4,5,{6,7}},3,{4,5,6,{7,8}}}, $hash4, 'data compares';

$hash1->{$_} = 9 for keys %$hash1;
$hash4->{$_} = 9 for keys %$hash4;

is_deeply {1,9,3,9}, $hash1, 'data compares';
is_deeply {0,9,1,9,2,9,3,9}, $hash4, 'data compares';
is_deeply {0,1,2,{3,4,5,{6,7}}}, $hash2, 'data compares';
is_deeply {0,1,1,2,2,{3,4,5,{6,7}},3,{4,5,6,{7,8}}}, $hash3, 'data compares';

*build_class = *MooX::Prototype::build_class;

my $classname = build_class();
ok $classname->can('new'), "$classname has a constructor";
is $classname, 'MooX::Prototype::Instance::__ANON__::0001', 'class generated';
isa_ok $classname, 'MooX::Prototype::Instance', 'class extends MooX::Prototype::Instance';

*build_attribute = *MooX::Prototype::build_attribute;

ok !$classname->can('color'), "$classname has no color attribute";
my $color = build_attribute($classname, 'color', 'blue');
ok $classname->can('color'), "$classname now has a color attribute";
my $object = $classname->new;
is ref($object), 'MooX::Prototype::Instance::__ANON__::0001', 'class object instantiated';
isa_ok $object, 'MooX::Prototype::Instance', 'object extends MooX::Prototype::Instance';
is $object->color, 'blue', "$object default color is set to blue";
is $object->color('black'), 'black', "$object color is set to black";

*build_method = *MooX::Prototype::build_method;

ok !$classname->can('palette'), "$classname has no palette method";
my $palette = build_method($classname, 'palette', sub { ['red', 'blue', 'green'] });
ok $classname->can('palette'), "$classname now has a palette method";
is_deeply $object->palette, ['red','blue','green'], "$object palette method returned";

*build_properties = *MooX::Prototype::build_properties;

$classname = build_class();
build_properties($classname => (
    color => 'red', palette => sub { ['red','black','green'] },
));
$object = $classname->new;
is ref($object), 'MooX::Prototype::Instance::__ANON__::0002', 'class object instantiated';
isa_ok $object, 'MooX::Prototype::Instance', 'object extends MooX::Prototype::Instance';
ok $classname->can('color'), "$classname has a color attribute";
is $object->color, 'red', "$object default color is set to red";
is $object->color('purple'), 'purple', "$object color is set to purple";
ok $classname->can('palette'), "$classname has a palette method";
is_deeply $object->palette, ['red','black','green'], "$object palette method returned";

*build_object = *MooX::Prototype::build_object;

$object = build_object(color => 'black', palette => sub { ['yellow','green'] });
is ref($object), 'MooX::Prototype::Instance::__ANON__::0003', 'class object instantiated';
isa_ok $object, 'MooX::Prototype::Instance', 'object extends MooX::Prototype::Instance';
ok $classname->can('color'), "$classname has a color attribute";
is $object->color, 'black', "$object default color is set to black";
is $object->color('brown'), 'brown', "$object color is set to brown";
ok $classname->can('palette'), "$classname has a palette method";
is_deeply $object->palette, ['yellow','green'], "$object palette method returned";

*build_clone = *MooX::Prototype::build_clone;

$object = build_clone($object);
is ref($object), 'MooX::Prototype::Instance::__ANON__::0004', 'class object instantiated';
isa_ok $object, 'MooX::Prototype::Instance', 'object extends MooX::Prototype::Instance';
ok $classname->can('color'), "$classname has a color attribute";
is $object->color, 'brown', "$object default color is set to brown";
is $object->color('black'), 'black', "$object color is set to black";
ok $classname->can('palette'), "$classname has a palette method";
is_deeply $object->palette, ['yellow','green'], "$object palette method returned";

ok 1 and done_testing;
