# MooX::Prototype Package Class
package MooX::Prototype::Package;

use Moo;
use Carp;

use Moo::Role ();

our $VERSION = '0.01'; # VERSION

has name => (
    is       => 'ro',
    required => 1
);

{
    no warnings 'redefine';

    sub after {
        my $self  = shift;
        my $class = $self->name;
        $class->can('after')->(@_);
        return;
    }

    sub around {
        my $self = shift;
        my $class = $self->name;
        $class->can('around')->(@_);
        return;
    }

    sub before {
        my $self = shift;
        my $class = $self->name;
        $class->can('before')->(@_);
        return;
    }
}

sub install {
    my $self  = shift;
    my $name  = shift or croak "Can't make without a name";
    my $code  = shift or croak "Can't make $name without a coderef";
    my $class = $self->name;

    no strict 'refs';
    no warnings 'redefine';
    *{"${class}::$name"} = $code;

    return;
}

sub include {
    my $self = shift;
    my %args = @_;

    my $class = $self->name;

    if (my $mixin = $args{class}) {
        Moo->_set_superclasses($class, $mixin);
        Moo->_maybe_reset_handlemoose($class);
    }

    if (my $role = $args{role}) {
        Moo::Role->apply_roles_to_package($class, $role);
        Moo->_maybe_reset_handlemoose($class);
    }

    return;
}

1;
