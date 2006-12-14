#!perl -wT
# $Id: basic.t 1603 2006-11-22 21:17:25Z claco $
use strict;
use warnings;

BEGIN {
    use lib 't/lib';
    use Handel::Test tests => 8;

    use_ok('Handel::Iterator::RDBO');
    use_ok('Handel::Schema::RDBO::Cart');
    use_ok('Handel::Schema::RDBO::Cart::Item');
    use_ok('Handel::Schema::RDBO::DB');
    use_ok('Handel::Storage::RDBO');
    use_ok('Handel::Storage::RDBO::Cart');
    use_ok('Handel::Storage::RDBO::Cart::Item');
    use_ok('Handel::Storage::RDBO::Result');
};
