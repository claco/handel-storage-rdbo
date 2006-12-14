#!perl -wT
# $Id$
use strict;
use warnings;

BEGIN {
    use lib 't/lib';
    use Handel::Test;

    plan skip_all => 'set TEST_MANIFEST or TEST_PRIVATE to enable this test' unless $ENV{TEST_MANIFEST} || $ENV{TEST_PRIVATE};

    eval 'use Test::CheckManifest 0.09';
    if($@) {
        plan skip_all => 'Test::CheckManifest 0.09 not installed';
    };
};

ok_manifest({
    exclude => ['/t/var', '/cover_db'],
    filter  => [qr/\.svn/, qr/cover/],
    bool    => 'or'
});
