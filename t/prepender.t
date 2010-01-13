#!perl

use strict;
use warnings;

use Dist::Zilla;
use File::Spec::Functions qw{ catdir catfile };
use Test::More tests => 20;

# build fake dist
chdir( catdir('t', 'foo') );
my $zilla = Dist::Zilla->from_config;
$zilla->build_in;
my $dir = 'Foo-1.23';

# check module & script
check_top_of_file( catfile($dir, 'lib', 'Foo.pm'), 0 );
check_top_of_file( catfile($dir, 'bin', 'foobar'), 1 );

exit;

sub check_top_of_file {
    my ($path, $offset) = @_;

    # slurp file
    open my $fh, '<', $path or die "cannot open '$path': $!";
    my @lines = split /\n/, do { local $/; <$fh> };
    close $fh;

    is( $lines[0+$offset], '# ' );
    is( $lines[1+$offset], '# This file is part of Foo' );
    is( $lines[2+$offset], '# ' );
    is( $lines[3+$offset], '# This software is copyright (c) 2009 by foobar.' );
    is( $lines[4+$offset], '# ' );
    is( $lines[5+$offset], '# This is free software; you can redistribute it and/or modify it under' );
    is( $lines[6+$offset], '# the same terms as the Perl 5 programming language system itself.' );
    is( $lines[7+$offset], '# ' );
    is( $lines[8+$offset], 'use strict;' );
    is( $lines[9+$offset], 'use warnings;' );
}
