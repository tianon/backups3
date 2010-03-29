#!/usr/bin/perl -w
use strict;
use warnings;

use FindBin; FindBin::again();
use lib "$FindBin::RealBin/libs";

use BackupS3;
use Data::Dumper;

my $global = BackupS3::parse_global_config('backups3_globalconfig');
print Dumper($global);
exit;

my $dir = 'sample-dir';
my $config = BackupS3::parse_backup_config("$dir/backups3");
my $final_file_list = BackupS3::get_final_file_list($dir, $config);
print Dumper(sort @$final_file_list);
