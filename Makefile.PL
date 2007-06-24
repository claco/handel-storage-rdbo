# $Id$
use strict;
use warnings;
use inc::Module::Install 0.65;

name 'Handel-Storage-RDBO';
license 'perl';
perl_version '5.008001';
all_from 'lib/Handel/Storage/RDBO.pm';

requires 'Handel'           => '1.00000';
requires 'Rose::Object'     => '0.84';
requires 'Rose::DB'         => '0.734';
requires 'Rose::DB::Object' => '0.764';
requires 'Clone';
requires 'Scalar::Util';

build_requires 'Directory::Scratch';

tests 't/*.t t/*/*.t';
clean_files 't/var Handel-Storage-RDBO-*';

eval {
    system 'pod2text lib/Handel/Storage/RDBO.pm > README';
};

auto_install;
WriteAll;
