#!/usr/bin/perl -w
use strict;
use warnings;

package BackupS3;

use File::Basename qw(dirname);
use Cwd qw(realpath cwd);
use File::Spec::Functions;
use File::Find;
use File::KGlob2RE qw(kglob2re);

sub parse_global_config {
	my ($filename) = @_;
	
	local @ARGV = ($filename);
	
	my %config = (
		backupConfigFilename => '.backups3',
		backupConfigEnforcedMode => '600',
		include => {}, # path => depth
	);
	
	my $current_key = undef;
	while (<>) {
		chomp;
		
		s/\s+$//;
		
		next if $_ eq ''; # skip blank lines
		
		next if m/^#/; # allow comments, but only if # is the first character on the line
		
		if (m/^(\S.*)$/) {
			my ($key) = ($1); # bucket, accessKeyId, secretAccessKey, include, exclude, exemption
			
			die "invalid configuration: $key is unknown" if !exists $config{$key};
			
			$current_key = $key;
			
			next;
		}
		
		if (m/^\t(\S.*)$/) {
			my ($value) = ($1);
			
			warn "no key defined yet, probably have garbage at the top of the file" and next if !defined $current_key;
			
			if ($current_key eq 'include') {
				if ($value =~ m! ^ ( [^|]+ ) \| ( \d+ | \* ) $ !x) {
					my ($path, $depth) = ($1, $2);
					$path = realpath($path);
					$config{$current_key}{$path} = int($depth);
				}
				else {
					warn "invalid include line: $value\n";
				}
			}
			else {
				$config{$current_key} = $value;
			}
			
			next;
		}
	}
	
	return \%config;
}

our $backup_config_single_keys = '^(bucket|accessKeyId|secretAccessKey)$';

sub parse_backup_config {
	my ($filename) = @_;
	
	local @ARGV = ($filename);
	
	my %config = ();
	
	my $current_key = undef;
	my $current_subkey = undef;
	while (<>) {
		chomp;
		
		s/\s+$//;
		
		next if $_ eq ''; # skip blank lines
		
		next if m/^#/; # allow comments, but only if # is the first character on the line
		
		if (m/^(\S.*)$/) {
			my ($key) = ($1); # bucket, accessKeyId, secretAccessKey, include, exclude, exemption
			
			if (!exists $config{$key}) {
				if ($key =~ m/$backup_config_single_keys/i) {
					$config{$key} = '';
				}
				else {
					$config{$key} = {};
				}
			}
			
			$current_key = $key;
			$current_subkey = undef;
			
			next;
		}
		
		if (m/^\t(\S.*)$/) {
			my ($value) = ($1);
			
			warn "no key defined yet, probably have garbage at the top of the file" and next if !defined $current_key;
			
			if ($current_key =~ m/$backup_config_single_keys/i) {
				$config{$current_key} = $value;
				$current_subkey = undef;
			}
			else {
				$config{$current_key}{$value} = [] if !exists $config{$current_key}{$value};
				$current_subkey = $value;
			}
			
			next;
		}
		
		if (m/^\t\t(.*)$/) {
			my ($value) = ($1);
			
			warn "no key defined yet, probably have garbage at the top of the file" and next if !defined $current_key;
			warn "no subkey defined yet, probably have garbage at the top of the key" and next if !defined $current_subkey;
			
			push @{$config{$current_key}{$current_subkey}}, $value;
		}
	}
	
	$config{'dir'} = realpath(dirname($filename));
	
	return \%config;
}

my %tree_cache = ();

sub parse_include {
	my ($dir, $conf) = (@_);
	
	$dir = realpath($dir);
	warn "$dir/ does not exist" and return [] if !-d $dir;
	
	# we use %tree_cache to ensure that we only do the expensive find() call once, even though we use the same directory structure info for include, exclude, and exemption
	if (!exists $tree_cache{$dir}) {
		$tree_cache{$dir} = [];
		find({
				wanted => sub {
					push @{$tree_cache{$dir}}, $File::Find::name;
				},
			}, $dir);
	}
	
	my @regexes = ();
	my %size_specs = (
		'gt' => [], # array of ints
		'lt' => [], # array of ints
		'between' => [], # array of pairs
	);
	
	# file
	if (exists $conf->{'file'}) {
		for my $file (@{$conf->{'file'}}) {
			push @regexes, "^\Q$dir/$file\E\$";
		}
	}
	
	# glob
	if (exists $conf->{'glob'}) {
		for my $glob (@{$conf->{'glob'}}) {
			my $regex = kglob2re($glob);
			$regex =~ s!^(\^)!$1\Q$dir\E/!g;
			push @regexes, $regex;
		}
	}
	
	# size
	if (exists $conf->{'size'}) {
		my $amnt = '(\d+)(|K|M|G|T)B?';
		my %mult = (
			'' => 1024 ** 0,
			k => 1024 ** 1,
			m => 1024 ** 2,
			g => 1024 ** 3,
			t => 1024 ** 4,
		);
		for my $size (@{$conf->{'size'}}) {
			if ($size =~ m/^less\s+th[ae]n\s+$amnt$/i) {
				my $val = $1 * $mult{lc $2};
				push @{$size_specs{'lt'}}, int $val;
			}
			elsif ($size =~ m/^greater\s+th[ae]n\s+$amnt$/i) {
				my $val = $1 * $mult{lc $2};
				push @{$size_specs{'gt'}}, int $val;
			}
			elsif ($size =~ m/^between\s+$amnt\s+and\s+$amnt$/i) {
				my $val1 = $1 * $mult{lc $2};
				my $val2 = $3 * $mult{lc $4};
				push @{$size_specs{'between'}}, [int $val1, int $val2];
			}
		}
	}
	
	# clean up @regexes
	for my $regex (@regexes) {
		$regex =~ s!\\/!/!g; # escaping / is not necessary for our purposes
		
		$regex =~ s!(\Q[^/]*\E){2,}!.*!g; # hack to allow ** to match any depth of subdirectory as well (so that **/* matches any file at any depth in any subdirectory)
		1 while $regex =~ s!
		/([^/.]{2}[^/]*|\.[^/.][^/]*|\.\.[^/]+)/\\\.\\\./ # turn /something/../ into /
		|
		/(\\\./)+ # turn /./ into / and /.$ into /
		|
		//+ # turn // into /
		!/!gx;
		
		$regex =~ s! ^ ( \^ / ) ( \\ \. \\ \. / )+ !$1!gx; # also clean out any /../ at the beginning of the string, because they're pointless
		
		$regex =~ s! (:? / \\.? )+ ( \$ ) $ !$1!gx; # also remove any trailing / checks, because they are not only useless, but screw up our detection of directories
	}
	
	my @ret = ();
	for my $file (@{$tree_cache{$dir}}) {
		$file = realpath($file);
		
		# not valid to begin with
		next if $file !~ m!^\Q$dir\E/!;
		
		my ($dev,$ino,$mode,$nlink,$uid,$gid) = lstat($file);
		my $file_size = int(-s _);
		
		$file = $file . '/' if -d _; # make directories easier to recognize
		
		# match @regexes
		for my $regex (@regexes) {
			goto dopush if $file =~ m!$regex!;
		}
		
		# match @size_specs (special thanks to find2perl script)
		for my $lt (@{$size_specs{'lt'}}) {
			goto dopush if $file_size <= $lt;
		}
		for my $gt (@{$size_specs{'gt'}}) {
			goto dopush if $file_size >= $gt;
		}
		for my $between (@{$size_specs{'between'}}) {
			my ($lower, $upper) = @$between;
			goto dopush if $file_size >= $lower && $file_size <= $upper;
		}
		
		next;
		
		dopush: push @ret, $file;
	}
	
	return \@ret;
}

sub array_subtract {
	my ($a, $b) = @_;
	
	my @ret = ();
	my %seenb = ();
	for my $e (@$b) {
		$seenb{$e} = 1;
	}
	
	for my $e (@$a) {
		push @ret, $e unless exists $seenb{$e};
	}
	
	return \@ret;
}

sub get_final_file_list {
	my ($dir, $config) = @_;
	
	my ($incl, $excl, $exemp) = ([], [], []);
	$incl = parse_include($dir, $config->{'include'}) if exists $config->{'include'};
	$excl = parse_include($dir, $config->{'exclude'}) if exists $config->{'exclude'};
	$exemp = parse_include($dir, $config->{'exemption'}) if exists $config->{'exemption'};
	
	return array_subtract($incl, array_subtract($excl, $exemp));
}

1;
