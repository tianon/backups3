#!/usr/bin/perl -w
use strict;
use warnings;

use FindBin; FindBin::again();
use lib "$FindBin::RealBin/libs";

use BackupS3;
use Data::Dumper;

my $global = BackupS3::parse_global_config('backups3_globalconfig');
my $inc = BackupS3::parse_global_include($global);

# this can be "forked" later for performance, if desired (and the "forking factor" could even be in the config file -- as in, the max number of concurrent instances)
for my $file (@$inc) {
	my $config = BackupS3::parse_backup_config($file);
	my $dir = $config->{'dir'};
	my $final_file_list = BackupS3::get_final_file_list($dir, $config);
	print Dumper($final_file_list);
	# TODO mount the AmazonS3 stuff and backup the files in $final_file_list
}
