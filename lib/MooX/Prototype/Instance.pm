# MooX::Prototype Instance Class
package MooX::Prototype::Instance;

use Moo ();
use Moo::Role ();

our $VERSION = '0.01'; # VERSION

*package = sub {
    require MooX::Prototype::Package;
    return MooX::Prototype::Package->new(
        name => ref($_[0]) || $_[0]
    )
};

my $c = 0;
my $m = 0;
sub DEMOLISH {
    my $self  = shift;
    my $class = ref($self) || $self;

    # nasty business all the way down
    $INC{'Class/MOP.pm'} and $c++ if !$c;
    Class::MOP::remove_metaclass_by_name($class) if $c;
    $INC{'Moo.pm'} and $m++ if !$m;
    delete $Moo::MAKERS{$class} if $m;

    unless ($class eq __PACKAGE__) {
        no strict 'refs';
        my $table = "${class}::";
        my %symbols = %$table;
        for my $symbol (keys %symbols) {
            next if $symbol =~ /\A[^:]+::\z/;
            delete $symbols{$symbol};
        }
        my $file = join('/', split('::', $class)) . 'pm';
        delete $INC{$file};
    }

    return 1;
}

1;
