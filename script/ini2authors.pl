#!/usr/bin/perl

use Modern::Perl;
use Config::IniFiles;
use Data::Dumper;
use File::Basename;
use DateTime;
use YAML::Syck;
use File::Path qw!make_path!;

die "No valid config file"
	unless $ARGV[0] and -r $ARGV[0];

my $ini = $ARGV[0];

my $cfg = Config::IniFiles->new(-file => $ini);

for my $val ( $cfg->Sections ) {
	next unless $val =~ m!^http://!; # no https even
	my $person = $cfg->val($val, 'name');
	my $filename = lc $person;
	
	$filename =~ s!\W+!_!g;
	my $abbr = $filename; $abbr =~ s![^a-z]!!g; $abbr = substr $abbr, 0, 2;
		
	my $file_dir = dirname(__FILE__)."/../authors/".substr($abbr, 0, 1)."/".$abbr;
	my $file = $file_dir.'/'.$filename;

	next if -f $file;
	
	say ".. creating directory: $file_dir";
	make_path($file_dir);
	
	say ".. creating object for ".$cfg->val($val, 'name').' in '.$cfg->val('Planet', 'country_tld');
	
	my $p = {
		url => $val,
		name => $cfg->val($val, 'name'),
		countries => [
			$cfg->val('Planet', 'country_tld'),
		],
		filename => $filename,
		enabled => 'on', # by default
		email => undef,
		twitter => undef,
		message => undef,
	};
	
	for my $i ( $cfg->Parameters($val) ) {
		next if $i eq 'name';
		$p->{$i} = $cfg->val($val, $i);
		
		if($i eq 'face') {
			$p->{$i} = $cfg->val('Planet', 'country_tld').'/'.$p->{$i}
		}		
	}
	
	DumpFile($file, $p);	
}
