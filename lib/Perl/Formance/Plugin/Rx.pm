package Perl::Formance::Plugin::Rx;

# Regexes

use warnings;
use strict;

use Time::HiRes qw(gettimeofday);
use Benchmark ':hireswallclock';
use Data::Dumper;

use vars qw($goal);
$goal = $ENV{PERLFORMANCE_TESTMODE_FAST} ? 5 : 23; # probably 28 or more

sub regexes
{
        my ($options) = @_;

        # http://swtch.com/~rsc/regexp/regexp1.html

        my $before;
        my $after;
        my $count = 3;
        my %results = ();

        {
                my $subtest = "pathological";

                my $n      = $goal;
                my $re     = ("a?" x $n) . ("a" x $n);
                my $string = "a" x $n;

                print STDERR " - $subtest...\n" if $options->{verbose} > 2;
                my $t = timeit $count, sub { $string =~ /$re/ };
                my $time = $t->[1] / $t->[5];
                $results{$subtest} = sprintf("%0.4f", $time);
        }

        # ----------------------------------------------------

        # { "abcdefg",	"abcdefg"	},
        # { "(a|b)*a",	"ababababab"	},
        # { "(a|b)*a",	"aaaaaaaaba"	},
        # { "(a|b)*a",	"aaaaaabac"	},
        # { "a(b|c)*d",	"abccbcccd"	},
        # { "a(b|c)*d",	"abccbcccde"	},
        # { "a(b|c)*d",	"abcccccccc"	},
        # { "a(b|c)*d",	"abcd"		},

        # ----------------------------------------------------

        {
                my $subtest = "fieldsplit1";

                my $re     = '(.*) (.*) (.*) (.*) (.*)';
                my $string = (("a" x 10_000_000) . " ") x 5;
                chop $string;

                print STDERR " - $subtest...\n" if $options->{verbose} > 2;
                my $t = timeit $count, sub { $string =~ /$re/ };
                my $time = $t->[1] / $t->[5];
                $results{$subtest} = sprintf("%0.4f", $time);
        }

        # ----------------------------------------------------

        {
                my $subtest = "fieldsplit2";

                my $re     = '([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*)';
                my $string = ( ("a" x 10_000_000) . " " ) x 5;
                chop $string;

                print STDERR " - $subtest...\n" if $options->{verbose} > 2;
                my $t = timeit $count, sub { $string =~ /$re/ };
                my $time = $t->[1] / $t->[5];
                $results{$subtest} = sprintf("%0.4f", $time);
        }

        $results{fieldsplitratio} = sprintf(
                                            "%0.4f",
                                            $results{fieldsplit2} / $results{fieldsplit1}
                                           );

        # ----------------------------------------------------

        return \%results;
}

sub main
{
        my ($options) = @_;

        return {
                regexes => regexes($options),
               };
}

1;

__END__

=head1 NAME

Perl::Formance::Plugin::FibThreads - Stress regular expressions

=cut

