package PlanetaLinux::Cmd::Command::add;
use PlanetaLinux::Cmd -command;

use Modern::Perl;
use Data::Dumper;
use File::Basename;
use WebService::Validator::Feed::W3C;
use Data::Validate::Email qw(is_email);
use File::Path 'make_path';
use File::MimeInfo::Simple;
use YAML::Syck;
use Image::Magick;

sub opt_spec {
	return (
		[ "feed=s", "feed URL -- mandatory" ],
		[ "name=s", "name of author of feed -- mandatory" ],
		[ "email=s", "email of author of feed -- mandatory" ],
		[ "countries=s", "country(ies) of author -- mandatory"],
		[ "hackergotchi=s", "path to the hackergotchi image -- optional" ],
		[ "portal|p", "portal site flag -- optional" ],
		[ "twitter=s", "twitter feed of author -- optional" ],
	)
}

sub description { <<"";
Adds a new author to Planeta Linux. The name, email, feed URL and
country where to place the author are mandatory. If the hackergotchi
image path is provided, the script will check the size for the image
and resize it if needed (ImageMagick needed). Any other flags and
values passed to this command will be appended on the resulting
YAML file.
 
Examples:
 
 $0 add \\
		--feed http://example.com/feed \\
		--name "Tía Chonita" \\
		--email tia\@chonita.com \\
		--countries ve \\
		--hackergotchi ~/images/chonita.jpg \\
		--twitter \@chonita
 
 $0 add \\
		--feed http://blog.wordpress.com/feed/atom \\
		--name "Isela Crelló" \\
		--email yeah\@yeah.com.mx \\
		--countries mx,sv,gt \\
 
 $0 add \\
		--feed http://cofradia.sucks/feed \\
		--portal \\
		...etc

}

sub abstract { "add a new feed to Planeta Linux" }

sub validate_args {
	my($self, $opt, $args) = @_;


	for my $c ( qw/feed name email countries/ ) {
		$self->usage_error("No `$c' provided.")
			unless $opt->{$c}
	}
	
	$self->usage_error("`$opt->{email}' doesn't look a a valid address.")
		unless is_email($opt->{email});
	
	if($opt->{hackergotchi}) {
		$self->usage_error("$opt->{hackergotchi} doesn't seem to exist.")
			unless -r $opt->{hackergotchi};
	}
	
	$self->usage_error("Wrong countries format: $opt->{countries}.")
		unless lc $opt->{countries} =~ /^[a-z]{2}(?:,[a-z]{2})*$/;
	
	$self->usage_error("Invalid extra arguments! ".join(' ', @$args))
		if @$args % 2;
	
	$self->usage_error("No valid feed provided.")
		unless $opt->{feed} =~ m!^http://!;
}

sub execute {
	my($self, $opt, $args) = @_;
	
	my $feed = $opt->{feed};
	my $pl = PlanetaLinux::Feeds->new;
	
	die "ERR: Feed already exists on authors/ directory.\n"
		if $pl->does_feed_exist($feed);

	my $val = WebService::Validator::Feed::W3C->new;
	my $ok = $val->validate(uri => $feed);	
	
	if($val->is_valid) {
		# say "Valid feed."
	} else {
		print Dumper $val->errors;
		print Dumper $val->warnings;
		die "Invalid file. Aborting.\n";
	}
	
	$self->_add_feed($opt, $args);
}

sub _add_feed {
	my($self, $opt, $args) = @_;

	my $filename = lc $opt->{name};
	$filename =~ s!\W+!_!g;
	my $abbr = $filename; $abbr =~ s![^a-z]!!g; $abbr = substr $abbr, 0, 2;
	my $file_dir = dirname(__FILE__)."/../../../../authors/".substr($abbr, 0, 1)."/".$abbr;
	
	my @countries = split ',', lc $opt->{countries};
	my $yaml = $file_dir."/$filename.yaml";

	my $s = {
		url => $opt->{feed},
		name => $opt->{name},
		countries => \@countries, #maybe check whether these are valid?
		filename => $filename.'.yml',
		enabled => 'on', # by default
		email => $opt->{email},
		twitter => $opt->{twitter},
		message => undef,
	};
	
	$s->{portal} = 1 if $opt->{portal};

	if($opt->{twitter}) {
		$s->{twitter} = $opt->{twitter};
		$s->{twitter} =~ s/\W//;
	}
	
	my %args = @$args;
	
	while(my ($k, $v) = each %args) {
		$k =~ s/^\-\-//;
		$s->{$k} = $v;
	}
	
	my $gotchi_dest;
	my $gotchi;
	if($opt->{hackergotchi}) {
		my $ext = (split '/', mimetype($opt->{hackergotchi}))[1];
	
		my $img = Image::Magick->new;
		$img->Read($opt->{hackergotchi});
		$gotchi = $img->Clone;
		$gotchi->Resize(geometry => '95x95');
		$gotchi_dest = dirname(__FILE__).'/../../../../www/images/cabezas/'.$countries[0]."/$filename".'.'.$ext;
		$s->{face} = $countries[0]."/$filename.$ext";
	}
	
	say "";
	say ".. I will create the following structure on file: ";
	say ".. ".$yaml;
	
	say Dump $s;
	
	print "- Are you sure you want to write this file? (y/n) ";
	chomp(my $ans = <STDIN>);
	
	die "Aborting then.\n" unless $ans =~ /^y$/i;	
	
	say ".. creating directory: $file_dir";
	make_path($file_dir);
	if($opt->{hackergotchi}) {
		say ".. rewriting image to: $gotchi_dest";
		$gotchi->Write($gotchi_dest);
	}
	say ".. writing yaml to: $yaml";
	DumpFile($yaml, $s);

	say "";
	say '`\o done `\o';
	
}

1;