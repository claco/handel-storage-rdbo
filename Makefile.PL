use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Handel::Storage::RDBO',
    AUTHOR              => 'Christopher H. Laco <claco@chrislaco.com>',
    VERSION_FROM        => 'lib/Handel/Storage/RDBO.pm',
    ABSTRACT_FROM       => 'lib/Handel/Storage/RDBO.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Handel-Storage-RDBO-*' },
);
