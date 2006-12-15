# $Id$
## no critic (ProhibitPostfixControls, ProhibitExcessComplexity)
package Handel::Schema::RDBO::DB;
use strict;
use warnings;

BEGIN {
    use base qw/Rose::DB/;
    use Handel::ConfigReader;
};
__PACKAGE__->use_private_registry;
__PACKAGE__->default_connect_options(PrintError => 0, Warn => 0);
__PACKAGE__->register_db(
    domain     => 'handel',
    type       => 'bogus',
    driver     => 'sqlite',
    autocommit => 1
);

sub dbh {
    my $self      = shift;
    my $cfg       = Handel::ConfigReader->instance;
    my $dsn       = $cfg->{'HandelDBIDSN'}      || $cfg->{'db_dsn'};
    my $user      = $cfg->{'HandelDBIUser'}     || $cfg->{'db_user'};
    my $pass      = $cfg->{'HandelDBIPassword'} || $cfg->{'db_pass'};
    my $db_driver = $cfg->{'HandelDBIDriver'}   || $cfg->{'db_driver'};
    my $db_host   = $cfg->{'HandelDBIHost'}     || $cfg->{'db_host'};
    my $db_port   = $cfg->{'HandelDBIPort'}     || $cfg->{'db_port'};
    my $db_name   = $cfg->{'HandelDBIName'}     || $cfg->{'db_name'};

    if (!$dsn && $db_driver && $db_name) {
        $dsn = "dbi:$db_driver:dbname=$db_name";

        if ($db_host) {
            $dsn .= ";host=$db_host";
        };

        if ($db_host && $db_port) {
            $dsn .= ";port=$db_port";
        };
    };

    my $args = {};
    $args->{'dsn'} = $dsn if $dsn;
    $args->{'driver'} = $db_driver if $db_driver;
    $args->{'host'} = $db_host if $db_host;
    $args->{'port'} = $db_port if $db_port;
    $args->{'database'} = $db_name if $db_name;
    $args->{'username'} = $user if $user;
    $args->{'password'} = $pass if $pass;

    $self->modify_db(%{$args}, domain => 'handel', type => 'bogus');

    return $self->SUPER::dbh;
};

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

=head1 METHODS

=head2 dbh

Establishes a connection to the database and returns a new db object. If
no connection information is supplied, the connection information will be read
from C<ENV> or ModPerl using the configuration options available in the
specified C<config_class>. By default, this will be
L<Handel::ConfigReader|Handel::ConfigReader>.

=head1 SEE ALSO

L<Rose::DB>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
