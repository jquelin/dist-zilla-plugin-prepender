
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  'build_requires' => {
    'Dist::Zilla::Tester' => '0',
    'File::Find' => '0',
    'File::Temp' => '0',
    'Module::Build' => '0.3601',
    'Path::Class' => '0',
    'Test::More' => '0.88'
  },
  'configure_requires' => {
    'Module::Build' => '0.3601'
  },
  'dist_abstract' => 'prepend lines at the top of your perl files',
  'dist_author' => [
    'Jerome Quelin'
  ],
  'dist_name' => 'Dist-Zilla-Plugin-Prepender',
  'dist_version' => '1.112280',
  'license' => 'perl',
  'module_name' => 'Dist::Zilla::Plugin::Prepender',
  'recommends' => {},
  'recursive_test_files' => 1,
  'requires' => {
    'Dist::Zilla::Role::FileMunger' => '0',
    'Moose' => '0',
    'MooseX::Has::Sugar' => '0',
    'perl' => '5.008'
  },
  'script_files' => []
);


my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
