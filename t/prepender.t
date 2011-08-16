#!perl
#
# This file is part of Dist-Zilla-Plugin-Prepender
#
# This software is copyright (c) 2009 by Jerome Quelin.
#
# This is free software; you can redistribute it and/or modify it under
# the same terms as the Perl 5 programming language system itself.
#

use strict;
use warnings;

use Dist::Zilla::Tester;
use Path::Class;
use Test::More tests => 31;

# build fake dist
my $tzil = Dist::Zilla::Tester->from_config({
    dist_root => dir(qw(t foo)),
});
chdir $tzil->tempdir->subdir('source');
$tzil->build;

# check module & script
my $dir = $tzil->tempdir->subdir('build');
check_top_of_file( file($dir, 'lib', 'Foo.pm'), 0 );
check_top_of_file( file($dir, 'bin', 'foobar'), 1 );
check_top_of_file( file($dir, 'bin', 'foobarbaz'), 1 );

is $tzil->slurp_file(file(qw(build t support.pl))),
   "# only used during tests\nuse strict;\n1;\n",
   'file ignored according to configuration';

exit;

sub check_top_of_file {
    my ($path, $offset) = @_;

    # slurp file
    open my $fh, '<', $path or die "cannot open '$path': $!";
    my @lines = split /\n/, do { local $/; <$fh> };
    close $fh;

    is( $lines[0+$offset], '#' );
    is( $lines[1+$offset], '# This file is part of Foo' );
    is( $lines[2+$offset], '#' );
    is( $lines[3+$offset], '# This software is copyright (c) 2009 by foobar.' );
    is( $lines[4+$offset], '#' );
    is( $lines[5+$offset], '# This is free software; you can redistribute it and/or modify it under' );
    is( $lines[6+$offset], '# the same terms as the Perl 5 programming language system itself.' );
    is( $lines[7+$offset], '#' );
    is( $lines[8+$offset], 'use strict;' );
    is( $lines[9+$offset], 'use warnings;' );
}
