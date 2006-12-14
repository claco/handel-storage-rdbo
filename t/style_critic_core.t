#!perl -w
# $Id: style_critic_core.t 1562 2006-11-10 03:54:54Z claco $
use strict;
use warnings;

BEGIN {
    use lib 't/lib';
    use Handel::Test;

    plan skip_all => 'set TEST_CRITIC or TEST_PRIVATE to enable this test' unless $ENV{TEST_CRITIC} || $ENV{TEST_PRIVATE};

    eval 'use Test::Perl::Critic 0.08';
    plan skip_all => 'Test::Perl::Critic 0.08 not installed' if $@;
};

Test::Perl::Critic->import(
    -profile  => 't/style_critic_core.rc',
    -severity => 1,
    -format   => "%m at line %l, column %c: %p Severity %s\n\t%r"
);

my @files = Test::Perl::Critic::all_code_files('lib');

BAIL_OUT('No code files were found') unless scalar @files;

plan tests => scalar @files;
for my $file (@files) {
    critic_ok($file, $file);
};
