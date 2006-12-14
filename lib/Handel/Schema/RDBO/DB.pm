# $Id$
package Handel::Schema::RDBO::DB;
use strict;
use warnings;

BEGIN {
    use base qw/Rose::DB/;
};
__PACKAGE__->use_private_registry;
__PACKAGE__->register_db(
    domain     => 'handel',
    type       => 'bogus',
    driver     => 'sqlite',
    autocommit => 1
);

1;
__END__

=head1 NAME

Handel::Schema::RDBO::DB - RDBO DB class for the Handel::Storage::RDBO

=head1 SYNOPSIS

    use Handel::Schema::RDBO::DB;
    use strict;
    use warnings;
    
    my $db = Handel::Schema::RDBO::DB->new(
        domain => 'handel', type => 'bogus'
    );

=head1 DESCRIPTION

Handel::Schema::RDBO::DB is a generic Rose::DB class for use as the default
connections used in Handel::Storage::RDBO classes.

=head1 SEE ALSO

L<Rose::DB>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
