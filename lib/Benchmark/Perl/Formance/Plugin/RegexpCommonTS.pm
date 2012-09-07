package Benchmark::Perl::Formance::Plugin::RegexpCommonTS;

use strict;
use warnings;

our $VERSION = "0.002";

#############################################################
#                                                           #
# Benchmark Code ahead - Don't touch without strong reason! #
#                                                           #
#############################################################

use File::Temp qw(tempfile tempdir);
use File::Copy::Recursive qw(dircopy);
use File::ShareDir qw(dist_dir);
use Time::HiRes qw(gettimeofday);

our $count;
our $recurse;

use Benchmark ':hireswallclock';

sub prepare {
        my ($options) = @_;

        my $dstdir = tempdir( CLEANUP => 1 );
        my $srcdir; eval { $srcdir = dist_dir('Benchmark-Perl-Formance-Cargo')."/RegexpCommonTS" };
        return if $@;

        print STDERR "# Prepare cargo RegexpCommon testsuite in $dstdir ...\n" if $options->{verbose} >= 3;

        dircopy($srcdir, $dstdir);

        (my $prove = $^X) =~ s!/perl([\d.]*)$!/prove$1!;
        print STDERR "# Use prove: $prove\n" if $options->{verbose};

        return {
                failed => "did not find executable prove",
                prove  => $prove,
               } unless $prove && -x $prove;

        return ($dstdir, $prove, $recurse);
}

sub nonaggregated {
        my ($dstdir, $prove, $recurse, $options) = @_;

        my $cmd = "cd $dstdir ; $^X $prove $recurse '$dstdir/t' 2>&1";
        print STDERR "# $cmd\n"   if $options->{verbose} >= 4;
        print STDERR "# Run...\n" if $options->{verbose} >= 3;

        my @output;
        my $t = timeit $count, sub { @output = map { chomp; $_ } qx($cmd) };

        my $maxerr = ($#output < 10) ? $#output : 10;
        print STDERR join("\n# ", "", @output[0..$maxerr])    if $options->{verbose} >= 4;

        return {
                Benchmark  => $t,
                prove_path => $prove,
                count      => $count,
               };
}

sub main {
        my ($options) = @_;

        $count   = $options->{fastmode} ? 1 : 5;
        $recurse = $options->{fastmode} ? "" : "-r";

        my ($dstdir, $prove, $recurse) = prepare($options);
        return { failed => "no Benchmark-Perl-Formance-Cargo" } if not $dstdir;

        return nonaggregated($dstdir, $prove, $recurse, $options);
}

1;

=pod

=head1 NAME

Benchmark::Perl::Formance::Plugin::RegexpCommonTS - RegexpCommon test suite as benchmark

=head1 ABOUT

This plugin runs a part of the RegexpCommon test suite.

=cut

