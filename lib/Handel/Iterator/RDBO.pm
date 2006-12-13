# $Id$
package Handel::Iterator::RDBO;
use strict;
use warnings;
use overload
        '0+'     => \&count,
        'bool'   => \&count,
        '=='     => \&count,
        fallback => 1;

BEGIN {
    use base qw/Handel::Iterator::List/;
    use Handel::L10N qw/translate/;
    use Scalar::Util qw/blessed/;
};

sub count {return shift->SUPER::count(@_)};

1;
__END__
