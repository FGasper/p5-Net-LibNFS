#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::FailWarnings;
use Test::Fatal;
use Test::Deep;

use Net::LibNFS ();

eval { require AnyEvent } or do {
    plan skip_all => $@;
};

my $nfs = Net::LibNFS->new();

my $err = exception {
    $nfs->mount('localhost', '/home' . rand);
};

cmp_deeply(
    $err,
    all(
        Isa('Net::LibNFS::X::NFSError'),
        methods(
            [ get => 'errno' ] => any(1, 5),
        ),
    ),
    'expected error',
) or diag explain $err;

done_testing;