#!perl -T

use Test::More tests => 2;

BEGIN {
	use_ok( 'Handel::Storage::RDBO' );
	use_ok( 'Handel::Storage::RDBO::Result' );
}

diag( "Testing Handel::Storage::RDBO $Handel::Storage::RDBO::VERSION, Perl $], $^X" );
