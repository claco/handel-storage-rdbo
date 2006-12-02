package Handel::Iterator::RDBO;
use strict;
use warnings;
use overload
        '0+'     => \&count,
        'bool'   => \&count,
        '=='     => \&count,
        fallback => 1;

BEGIN {
    use base qw/Handel::Iterator/;
    use Handel::L10N qw/translate/;
    use Scalar::Util qw/blessed/;
};

1;
__END__
