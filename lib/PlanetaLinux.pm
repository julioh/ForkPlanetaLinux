#!/usr/bin/perl

package PlanetaLinux;

use Modern::Perl;
use PlanetaLinux::Feeds;
use Data::Dumper;
use Carp;
use File::Basename;
use File::Temp;
use Net::Domain::ES::ccTLD '0.03';

sub new {
	my $self = shift;
	my $ref = shift || {};

	$ref->{_t} = Template->new(
			INCLUDE_PATH => dirname(__FILE__).'/../template',
	);

	return bless $ref, $self;
}

sub is_country_supported {
	my($self) = shift;
	my $c = shift;
	
	open my $fh, "<", dirname(__FILE__).'/../config/countries.list'
		or die "Couldn't read countries list: $!";
	
	while(<$fh>) {
		chomp;
		return 1 if $self->country eq $_; 
	}
	
	0;
}

sub country {
	my($self) = shift;
	$self->{country} = $_[0] if $_[0];
	$self->{country};
}

sub analytics_id {
	my($self) = shift;
	
	open my $fh, "<", dirname(__FILE__).'/../config/analytics.list';
	my $cont = $self->country;
	while(<$fh>) {
		chomp;
		
		next unless $_ =~ /^$cont:/;
		return (split ':', $_)[1]
	}
	close $fh;
	return '';
}

sub country_name {
	my($self) = shift;
		
	find_name_by_cctld( $self->country );
}

sub run {
	my($self) = shift;
	my @countries = @_ || @{ $self->{countries} };
	
	for my $c ( @countries ) {
		# generate template
		$self->country($c);
		
		$self->country_name;
		croak "No instance found for $c"
			unless $self->is_country_supported;
		
		my $template = $self->template;
		my $ini = $self->feeds({country => $self->country})->by_country->ini({tmp_template => $template});
				
		my $dir = dirname(__FILE__).'/../';
		
		mkdir "$dir/cache/$c";

		`find $dir -type f -name "*.tmplc" -exec rm -f '{}' \\;`;
		
		# hacerlo de una mejor forma?
		my $venus = dirname(__FILE__).'/../venus/planet.py';
		
		`$venus $ini`;
		
	}
}

sub countries {
	my($self) = shift;
	open my $fh, "<", dirname(__FILE__).'/../config/countries.list'
		or die "Couldn't read countries list: $!";
	my @ret;
	while(<$fh>) {
		chomp;
		push @ret, $_;
	}
	close $fh;
	return @ret;
	
}

sub template {
	my $self = shift;
		
	my $countries = [];
	
	for my $c ( $self->countries ) {
		push @$countries, {
			tld => $c,
			name => find_name_by_cctld($c) || die "No country for `$c'",
		};
	}
		
	$self->{_t}->process('index.html.tmpl', {
		analytics_id => $self->analytics_id,
		instance_name => $self->country_name,
		instance_name_pure => _normalize_name($self->country_name),
		instance_code => $self->country,
		countries => $countries,
	}, dirname(__FILE__).'/../tmp/'.$self->country.'/index.html.tmpl')
		or die "Couldn't process template!".$self->{_t}->error;
	
	return dirname(__FILE__).'/../tmp/'.$self->country.'/index.html.tmpl';

}

sub template_file {
	my($self) = shift;
	$self->{template_file} = $_[0] if $_[0];
	$self->{template_file};
}


sub feeds {
	my($self) = shift;	
	return PlanetaLinux::Feeds->new(shift);
	
}

# somebody shoot me please
sub _normalize_name {
	my $x = $_[0];
	$x =~ s/á/a/;
	$x =~ s/é/e/;
	$x =~ s/í/i/;
	$x =~ s/ó/o/;
	$x =~ s/ú/u/;
	$x =~ s/ñ/n/;
	$x;
}

1;