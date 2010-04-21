#!/usr/bin/perl -w
use strict;
#use diagnostics; # warnings in more detail

use CGI qw/:standard *table *Tr *td/;
use CGI::Carp 'fatalsToBrowser';

use FindBin; FindBin::again();
use lib "$FindBin::RealBin/../libs";

use BackupS3;
use URI::Escape;
use CGI::Session;
use File::Spec::Functions qw(catfile catdir tmpdir);

my $sess = new CGI::Session('driver:File', cookie('CGISESSID') || undef, {
		Directory => tmpdir(),
	});

my $exitTo = param('exitTo') || $sess->param('exitTo');
my $bucket = param('bucket') || $sess->param('bucket');
my $accessKeyId = param('accessKeyId') || $sess->param('accessKeyId');
my $secretAccessKey = param('secretAccessKey') || $sess->param('secretAccessKey');

$sess->param('exitTo', $exitTo);
$sess->param('bucket', $bucket);
$sess->param('accessKeyId', $accessKeyId);
$sess->param('secretAccessKey', $secretAccessKey);

my $doExit = param('doExit');
if ($doExit) {
	$sess->clear(['exitTo', 'bucket', 'accessKeyId', 'secretAccessKey']);
	print redirect($exitTo || 'https://backups3.weyard.net/s3login.php');
	exit;
}

my $doDownload = param('doDownload');
if ($doDownload) {
	my $file = BackupS3::bucket_get_file($bucket, $accessKeyId, $secretAccessKey, $doDownload);
	if (defined $file) {
		print header({
				-type => 'application/octet-stream',
				-content_disposition => 'attachment; filename="' . $doDownload . '"',
				-cookie => cookie(CGISESSID => $sess->id()),
			});
		print $file->{'value'};
		exit;
	}
}

my $haveInfo = defined $bucket && defined $accessKeyId && defined $secretAccessKey;

if ($haveInfo && request_method() eq 'POST') {
	print redirect(url);
	exit;
}

print header({
		-type => 'text/html',
		-charset => 'utf-8',
		-cookie => cookie(CGISESSID => $sess->id()),
	});

print start_html({
		-title => (
			$haveInfo
			? 'BackupS3: ' . $bucket
			: 'BackupS3 Login'
		),
		-style => {-src => [
			'style.css',
			]},
		-encoding => 'utf-8',
	});

print start_table({
		-style => 'width: 100%; text-align: center;',
	})
. start_Tr
. start_td({
		-style => 'border: 1px solid black; vertical-align: middle;',
	});

if (!$haveInfo) {
	print h1('BackupS3 Login');
	
	print start_form(
		-method => 'post',
		-action => url,
	);
	
	my $autoEscape = autoEscape(0); # save and disable
	my $submitButton = submit(-value => 'View Files &raquo;');
	autoEscape($autoEscape); # restore
	
	print table({
			-class => 'login',
		},
		Tr(
			th(label({
						-for => 'bucket',
					}, 'Bucket Name:')),
			td(textfield(-id => 'bucket', -name => 'bucket', -value => $bucket)),
		),
		Tr(
			th(label({
						-for => 'accessKeyId',
					}, 'Access Key ID:')),
			td(textfield(-id => 'accessKeyId', -name => 'accessKeyId', -value => $accessKeyId)),
		),
		Tr(
			th(label({
						-for => 'secretAccessKey',
					}, 'Secret Access Key:')),
			td(textfield(-id => 'secretAccessKey', -name => 'secretAccessKey', -value => $secretAccessKey)),
		),
		Tr(
			td({
					-colspan => 2,
					-style => 'text-align: right;',
				}, hidden(-name => 'exitTo', -value => url), $submitButton),
		),
	);
	
	print end_form;
}
else {
	print h1("BackupS3: $bucket");
	print div({
			-style => 'margin-bottom: 1em;',
		}, a({
				-href => url(-relative => 1) . '?doExit=1',
			}, "&laquo; Exit"));
	
	my $keys = BackupS3::bucket_list($bucket, $accessKeyId, $secretAccessKey);
	
	for my $key (@$keys) {
		print div({
			}, a({
					-href => url(-relative => 1) . '?doDownload=' . uri_escape($key->{'key'}),
				}, $key->{'key'}) . ' (' . $key->{'size'} . ' bytes)');
	}
}

print end_td
. end_Tr
. end_table
. end_html;
