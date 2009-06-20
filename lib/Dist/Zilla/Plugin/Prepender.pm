package Dist::Zilla::Plugin::Prepender;
# ABSTRACT: prepend lines at the top of your perl files

use Moose;
with 'Dist::Zilla::Role::FileMunger';


# -- attributes

# accept some arguments multiple times.
sub multivalue_args { qw{ line } }

has _lines => (
  is         => 'ro',
  isa        => 'ArrayRef',
  lazy       => 1,
  auto_deref => 1,
  init_arg   => 'line',
  default    => sub { [] },
);


# -- public methods

sub munge_file {
    my ($self, $file) = @_;

    return $self->_munge_perl($file) if $file->name    =~ /\.(?:pm|pl)$/i;
    return $self->_munge_perl($file) if $file->content =~ /^#!(?:.*)perl(?:$|\s)/;
    return;
}

# -- private methods

#
# $self->_munge_perl($file);
#
# munge content of perl $file: add stuff at the top of the file
#
sub _munge_perl {
    my ($self, $file) = @_;
    my $stuff = join "\n", $self->_lines;
    my @lines = split /\n/, $file->content;

    # if there's a shebang line, insert stuff just after it
    my $id = ( $lines[0] =~ /^#!(?:.*)perl(?:$|\s)/ ) ? 1 : 0;

    splice @lines, $id, 0, $stuff;
    $file->content(join "\n", @lines);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

__END__

=begin Pod::Coverage

multivalue_args
munge_file

=end Pod::Coverage

=head1 SYNOPSIS

In your F<dist.ini>:

    [Prepender]
    line = # This file is part of Foo::Bar
    line = # Foo::Bar is copyright...
    line = use strict;
    line = use warnings;

=head1 DESCRIPTION

This plugin will prepend the specified lines in each Perl module or
program within the distribution. For scripts having a shebang line,
lines will be inserted just after it.

This is useful to enforce a set of pragmas to your files (since pragmas
are lexical, they will be active for the whole file), or to add some
copyright comments, as the fsf recommends.

