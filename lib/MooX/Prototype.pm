# ABSTRACT: Prototype-based Programming
package MooX::Prototype;

use Carp;

our $VERSION = '0.02'; # VERSION

sub import {
    my $class  = shift;
    my $target = caller;

    no strict 'refs';
    *{"${target}::extend"} = $class->can('build_clone');
    *{"${target}::object"} = $class->can('build_object');

    return;
}

sub build_args {
    my $left  = shift or return;
    my $right = shift or return;
    my $data;

    my $hash = {%$left};
    return $hash unless 'HASH' eq ref $right;

    while (my($key, $val) = each %$right) {
        if ('HASH' eq ref $val) {
            $hash->{$key} = build_args({}, $val);
        }
        elsif ('ARRAY' eq ref  $val) {
            $hash->{$key} = [
                map { 'HASH' eq ref $_ ? build_args({}, $_) : $_ } @$val
            ];
        }
        else {
            $hash->{$key} = $val;
        }
    }

    return $hash;
}

sub build_attribute ($$$) {
    my $class = shift;
    my $key   = shift;
    my $value = shift;

    $class = ref($class) || $class;
    my @default = (default => $value) if defined $value;
    $class->can('has')->($key => (is => 'rw', @default));

    return $value;
}

my $serial = 0;
sub build_class (;$) {
    my $base  = shift;
    my $class = join '::', __PACKAGE__, 'Instance';

    $base //= $class;

    my $name = sprintf '%s::__ANON__::%04d', $class, ++$serial;
    my $modern = $base->isa($class) || $base eq $class;
    my $inherit = $modern ? "extends '$base'" : "use base '$base'";

    eval join ';', ("package $name", "use Moo", $inherit);
    croak $@ if $@;

    return $name;
}

sub build_clone (@) {
    my $class  = shift;
    my $common = join '::', __PACKAGE__, 'Instance';

    my $base = ref($class) || $class;
    my $args = ref($class) ? {%{$class}} : {};
    build_properties(my $name = build_class($base), @_);

    return $name->new(
        $base->isa($common) ? (%{build_args(build_args({},$args), {@_})}) : @_
    );
}

sub build_method ($$$) {
    my $class = shift;
    my $key   = shift;
    my $value = shift;

    $class = ref($class) || $class;
    return unless 'CODE' eq ref $value;

    no strict 'refs';
    no warnings 'redefine';
    *{"${class}::$key"} = $value;

    return $value;
}

sub build_properties ($;@) {
    my $class = shift;
    my %properties = @_;

    $class = ref($class) || $class;
    while (my ($key, $val) = each %properties) {
        my $is_code = 'CODE' eq ref $val;
        build_method $class, $key, $val and next if $val and $is_code;
        build_attribute $class, $key, ref $val ? sub { $val } : $val;
    }

    return;
}

sub build_object (@) {
    build_properties(my $name = build_class, @_);
    return $name->new;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

MooX::Prototype - Prototype-based Programming

=head1 VERSION

version 0.02

=head1 SYNOPSIS

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

    if ($papa && $mama && $baby && $baby->begets($papa)) {
        my $statement = "The %s said, '%s'\n";

        printf $statement, $papa->name, $papa->responds;
        printf $statement, $mama->name, $mama->responds;
        printf $statement, $baby->name, $baby->responds;

        # The Papa Bear said, "Who's been eating my porridge?"
        # The Mama Bear said, "Who's been eating my porridge?"
        # The Baby Bear said, "Who's eaten up all my porridge?"
    }

=head1 DESCRIPTION

MooX::Prototype implements a thin prototype-like layer on top of the L<Moo>
object system. This module allows you to develop using a prototype-based style
in Perl, giving you the ability to create, mutate, extend, mixin, and destroy,
classes, components and objects ad hoc and with very little code.

Prototype-based programming is a style of object-oriented programming in which
classes are not present, and behavior reuse (known as inheritance in class-based
languages) is performed via a process of cloning existing objects that serve as
prototypes. Due to familiarity with class-based languages such as Java, many
programmers assume that object-oriented programming is synonymous with
class-based programming.

However, class-based programming is just one kind of object-oriented programming
style, and other varieties exist such as role-oriented, aspect-oriented and
prototype-based programming. A prominent example of a prototype-based
programming language is ECMAScript (a.k.a. JavaScript or JScript). B<Note: This
is an early release available for testing and feedback and as such is subject to
change.>

=head2 OVERVIEW

    my $movie = object;

The object function, exported by MooX::Prototype, creates an anonymous
class object (blessed hashref), derived from L<MooX::Prototype::Instance>.
The function can optionally take a list of key/value pairs. The keys with values
which are code references will be implemented as class methods, otherwise
will be implemented as class attributes.

    my $shrek = object
        name      => 'Shrek',
        filepath  => '/path/to/shrek',
        lastseen  => sub { (stat(shift->filepath))[8] },
        directors => ['Andrew Adamson', 'Vicky Jenson'],
        actors    => ['Mike Myers', 'Eddie Murphy', 'Cameron Diaz'],
    ;

As previously stated, with prototype-based programming, reuse is commonly
achieved by extending prototypes (i.e. cloning existing objects which also serve
as templates). The extend function, also exported by MooX::Prototype,
creates an anonymous class object (blessed hashref), derived from the specified
class or object.

    my $shrek2 = extend $shrek,
        name     => 'Shrek2',
        filepath => '/path/to/shrek2',
    ;

    # additional credited director
    my $directors = $shrek2->directors;
    push @$directors, 'Conrad Vernon';

The thing being extended does not have to be an existing prototype, you can
actually extend any class or blessed object you like (provided that the
underlying structure is a hashref). You don't even have to preload the module,
simply pass the class name to the extend function, along with any parameters you
would like the class to be instantiated with. Please note that what is returned
is not an instance of the class specified, instead, what will be returned is a
prototype derived from the class specified.

    my $imdb_search = extend 'IMDB::Film' => (
        crit => $shrek2->name,
    );

    $shrek2 = extend $shrek2 => (
        imdb_search => $imdb_search,
    );

Any objects created via prototype can be mutated using the install and include
methods, provided by L<MooX::Prototype::Package>, which uses the API of the
underlying object system to extend the subject. Every prototype object, which is
an instance of L<MooX::Prototype::Instance>, has a default method, called
package, which returns a L<MooX::Prototype::Package> instance, which is a class
used to manipulate the associated prototype instance.

The include method, using the class key, upgrades the subject (i.e. the
prototype instance) using multiple inheritance. Please note that calling this
method more than once will replace your superclasses, not add to them.

    # replaces existing superclass with testing superclass
    $film_search->package->include(class => 'Test::Search');

The include method, using the role key, modifies the subject using role
composition. Please note that applying a role will not overwrite existing
methods. If you desire to overwrite existing methods, please extend the object,
then apply the roles desired.

    # add credentials and request methods dynamically
    $film_search->package->include(role => 'Test::Auth');
    $film_search->package->include(role => 'Test::Search::Advanced');

One of the very cool and interesting practices that this style of programming
encourages is modifying class definitions at runtime. This is achieved using
standard modern Perl object system operations. For example:

    my $donkey = object;
    my $shrek  = object;

    $donkey->package->install(line => sub {
        'Shrek!'
    });

    $shrek->package->install(line => sub {
        'What? It's a compliment. Better out than in, I always say.'
    });

    $donkey->package->around(line => sub {
        my ($orig, $self) = (shift, shift);
        join ', ', $self->$orig, $shrek->line;
    });

    say $donkey->line;

=head1 AUTHOR

Al Newkirk <anewkirk@ana.io>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Al Newkirk.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
