package PlanetaLinux::Feeds;

use Modern::Perl;
use File::Find;
use File::Basename;
use Data::Dumper;
use YAML::Syck;
use Template;
use Net::Domain::ES::ccTLD;

use Carp;

sub new {
	my($self) = shift;
	my $p = shift;	
	my @feeds = ();
	
	find sub {
		return unless -f $_;
		my $f = LoadFile($_);
		push @feeds, $f
			if $f->{enabled}
				and $f->{enabled} eq ($p->{disabled} ? 'off' : 'on')
	}, dirname(__FILE__).'/../../authors';
		
	return bless {
		country => $p->{country},
		_feeds => \@feeds,
		_t => Template->new(
			INCLUDE_PATH => dirname(__FILE__).'/../../template',
		) || die Template->error,
	}, $self;
}

sub does_feed_exist {
	my($self) = shift;
	my $feed = shift;
	
	for my $f ( @{ $self->{_feeds} } ) {
		return 1 if $feed eq $f->{url}
	}
	0;
	# my($self, $feed) = @_;
	# 
	# for my $f ( @{ $self->feeds } ) {
	# 	return 1 if $feed eq $f->{url};
	# }
	# 
	# 0;
}

sub by_country {
	my($self) = shift;
	my $country = $self->{country};
	
	croak "no countries specified"
		unless $country;
	
	my $ret = [];
		
	for my $f ( @{ $self->{_feeds}} ) {
		for my $c ( @{ $f->{countries} } ) {
			push @$ret, $f
				if $country eq $c;
		}
	}
	
	$self->{_feeds} = $ret;
	return $self;
	
}

sub ini {
	my($self) = shift;
	my $p = shift;
	my($country) = $self->{country};
	
	$self->{_t}->process('config.ini.tmpl', {
		rss_template => dirname(__FILE__).'/../../template/rss.xml.tmpl',
		tmp_template => $p->{tmp_template},
		country_tld => $country,
		country_name => find_name_by_cctld( $country ),
		feeds => [map {
			my $f = $_;
			delete $f->{$_} for qw/countries/;
		
			for (keys %$f) {
				delete $f->{$_}
					unless $f->{$_}
			}
			$f;
		} @{ $self->{_feeds} } ],
	}, dirname(__FILE__).'/../../tmp/'.$country.'/config.ini');
	
	dirname(__FILE__).'/../../tmp/'.$country.'/config.ini';

}

1;