use 5.008;
use strict;
use warnings;

package Dist::Zilla::Plugin::Prepender;
# ABSTRACT: prepend lines at the top of your perl files

use Moose;
use MooseX::Has::Sugar;

with 'Dist::Zilla::Role::FileMunger';


# -- attributes

# accept some arguments multiple times.
sub mvp_multivalue_args { qw{ line skip } }

has copyright => ( ro, default => 1 );
has _lines => (
    ro, lazy, auto_deref,
    isa        => 'ArrayRef[Str]',
    init_arg   => 'line',
    default    => sub { [] },
);
has _skips => (
    ro, lazy, auto_deref,
    isa        => 'ArrayRef[Str]',
    init_arg   => 'skip',
    default    => sub { [] },
);


# -- public methods

sub munge_file {
    my ($self, $file) = @_;

    foreach my $skip ( $self->_skips ){
        return if $file->name =~ $skip;
    }

    if ($file->does('Dist::Zilla:Role::MutableFile'))
    {
        $self->log_debug($file->name . ' is not a mutable type, skipping...');
        return;
    }

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

my %re = (
  shebang   => qr/^#!(?:.*)perl(?:$|\s.*$)/m,
  vimmode   => qr/^#\s*(?:vim?|ex):.*$/m,
  emacsmode => qr/^#\s*-\*-[^\n]+?-\*-.*$/m,
);

sub _munge_perl {
    my ($self, $file) = @_;
    my @prepend;

    # add copyright information if requested
    if ( $self->copyright ) {
        my @copyright = (
            '',
            "This file is part of " . $self->zilla->name,
            '',
            split(/\n/, $self->zilla->license->notice),
            '',
        );
        push @prepend, map { length($_) ? "# $_" : '#' } @copyright;
    }

    # add hand-written lines to prepend
    push @prepend, $self->_lines;
    my $prepend = join "\n", @prepend;

    # insertion point depends if there's a shebang line
    my $content = $file->content;
    if ( $content =~ /\A$re{shebang}\n(?:$re{vimmode}|$re{emacsmode})/ ) {
      # skip two lines
        $content =~ s/\A([^\n]+\n[^\n]+\n)/$1$prepend\n/;
    } elsif ( $content =~ /\A(?:$re{shebang}|$re{vimmode}|$re{emacsmode})/ ) {
      # skip one line
        $content =~ s/\n/\n$prepend\n/;
    } else {
        $content =~ s/\A/$prepend\n/;
    }
    $file->content($content);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

__END__

=for Pod::Coverage
    mvp_multivalue_args munge_file


=head1 SYNOPSIS

In your F<dist.ini>:

    [Prepender]
    copyright = 0
    line = use strict;
    line = use warnings;
    skip = t/data/.+\.pl
    skip = something-else-unnecessary

=head1 DESCRIPTION

This plugin will prepend the specified lines in each Perl module or
program within the distribution. For scripts having a shebang line,
lines will be inserted just after it.

This is useful to enforce a set of pragmas to your files (since pragmas
are lexical, they will be active for the whole file), or to add some
copyright comments, as the fsf recommends.

The module accepts the following options in its F<dist.ini> section:

=over 4

=item * copyright - whether to insert a boilerplate copyright comment.
defaults to true.

=item * line - anything you want to add. may be specified multiple
times. no default.

=item * skip - regexp of file names to not prepend to.
may be specified multiple times. no default.

=back



=head1 SEE ALSO

You can look for information on this module at:

=over 4

=item * Search CPAN

L<http://search.cpan.org/dist/Dist-Zilla-Plugin-Prepender>

=item * See open / report bugs

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Dist-Zilla-Plugin-Prepender>

=item * Mailing-list (same as L<Dist::Zilla>)

L<http://www.listbox.com/subscribe/?list_id=139292>

=item * Git repository

L<http://github.com/jquelin/dist-zilla-plugin-prepender>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Dist-Zilla-Plugin-Prepender>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Dist-Zilla-Plugin-Prepender>

=back

