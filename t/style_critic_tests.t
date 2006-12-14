#!perl -w
# $Id: style_critic_tests.t 1569 2006-11-11 03:54:34Z claco $
use strict;
use warnings;

BEGIN {
    use lib 't/lib';
    use Handel::Test;
    use File::Spec::Functions qw/catfile/;

    plan skip_all => 'set TEST_CRITIC or TEST_PRIVATE to enable this test' unless $ENV{TEST_CRITIC} || $ENV{TEST_PRIVATE};

    eval 'use Test::Perl::Critic 0.08';
    plan skip_all => 'Test::Perl::Critic 0.08 not installed' if $@;
};

Test::Perl::Critic->import(
    -profile  => 't/style_critic_tests.rc',
    -severity => 1,
    -only     => 1,
    -format   => "%m at line %l, column %c: %p Severity %s\n\t%r"
);

my @files;
opendir(DIR, 't');
    push @files, map {catfile 't', $_} grep {m/^.*\.t$/} sort readdir(DIR);
closedir DIR;

BAIL_OUT('No test files were found') unless scalar @files;

plan tests => scalar @files;
for my $file (@files) {
    critic_ok($file, $file);
};
