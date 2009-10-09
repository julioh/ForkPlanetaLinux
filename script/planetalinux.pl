#!/usr/bin/perl

use Modern::Perl;
use File::Basename;

use lib dirname(__FILE__)."/../lib";
use PlanetaLinux::Cmd;
PlanetaLinux::Cmd->run;

__END__
=head1 NAME

planetalinux - Simple tool to query the Planeta Linux database

=head1 SYNOPSIS

 planetalinux -add http://example.com/feed