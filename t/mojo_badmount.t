#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::FailWarnings -allow_deps => 1;

use Net::LibNFS;

eval { require Mojo::IOLoop } or do {
    plan skip_all => $@;
};

my $obj = Net::LibNFS->new()->mojo();
isa_ok($obj, 'Net::LibNFS::Async', 'return from new()');

my $err;

my $p = $obj->mount('localhost', '/home' . rand)->then(
    sub {
        die "promise OK (?!?)";
        die "should have failed";
    },
    sub {
        $err = shift || 'failure was falsy??';
        die "promise failed ($err)";
    },
)->finally( sub {
    diag "stopping loop";
    Mojo::IOLoop->stop();
} );

diag "starting loop";
Mojo::IOLoop->start();
diag "after loop";

isa_ok(
    $err,
    'Net::LibNFS::X::Base',
    'either localhost isn’t an NFS server, or we connect to nonexistent export',
) or diag explain $err;

ok(
    $err->isa('Net::LibNFS::X::BadConnection') || $err->isa('Net::LibNFS::X::NFSError'),
    'one of the expected error classes',
);

done_testing;

