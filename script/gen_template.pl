#!/usr/bin/perl

# Copyright (c) 2009 David Moreno <david@axiombox.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

use Modern::Perl;
use File::Basename;
use Config::IniFiles;
use Data::Dumper;
use Template;

die "No instance specified\n" unless $ARGV[0];
my $instance_code = lc $ARGV[0];

my $config = dirname(__FILE__).'/../proc/'.$instance_code.'/config.ini';
die "Instance $instance_code doesn't exist\n" unless -f $config;

my $cfg = Config::IniFiles->new(-file => $config);
my $instance_name = $cfg->val('Planet', 'country');

die "Couldn't find code name for $instance_code\n" unless $instance_name;

opendir my $dir, dirname(__FILE__).'/../proc' or die "Couldn't open proc dir: $!";
my @instances = sort grep {
	!/^\./ and $_ ne 'test' and $_ ne 'universo' and -f dirname(__FILE__).'/../proc/'.$_.'/config.ini';
} readdir $dir;
close $dir;

my $html = qq{\t<li id="home"><a href="http://www.planetalinux.org" title="Planeta Linux | Página Principal">home</a></li>\n};

for my $i ( @instances ) {
	$html .= qq{\t<li id="$i"};
	if($i eq $instance_code) {
		$html .= qq{ class="current">};
	} else {
		$html .= qq{>};
	}
	
	my $i_config = dirname(__FILE__).'/../proc/'.$i.'/config.ini';
	my $i_cfg = Config::IniFiles->new(-file => $i_config);
	my $i_name = $i_cfg->val('Planet', 'country');
	$html .= qq{<a href="../$i" title="Planeta Linux | $i_name">$i_name</a></li>\n};
}

my $t = Template->new;

$t->process(\*DATA, {
	adsense_id => $cfg->val('Planet', 'adsense_id'),
	instance_name => $instance_name,
	instance_name_pure => normalize_name($instance_name),
	instance_code => $instance_code,
	instances_list => $html,
}, dirname(__FILE__).'/../proc/'.$instance_code.'/index.html.tmpl');


# please, somebody fix this stupidity
# i'm in a hurry, fix later.
sub normalize_name {
	my $x = $_[0];
	$x =~ s/á/a/;
	$x =~ s/é/e/;
	$x =~ s/í/i/;
	$x =~ s/ó/o/;
	$x =~ s/ú/u/;
	$x =~ s/ñ/n/;
	$x;
}







# 
# CHAN CHAN CHAAAAAAAAAAAAAAAAAAAAAAAAAAAAN
#

__END__
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="es" lang="es">
<head>
<title><TMPL_VAR name></title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link rel="stylesheet" href="../css/main.css" type="text/css" />
<link rel="shortcut icon" type="image/png" href="../images/favicon.png" />
<link rel="alternate" type="application/rss+xml" title="Planeta Linux | [% instance_name %]" href="http://feedproxy.google.com/PlanetaLinux[% instance_name_pure.remove('\s+') %]" />

</head>

<body>
<div id="header">
  <div id="inside">
    <h1 id="header-title"><a href="../[% instance_code %]" title="Planeta Linux | [% instance_name %]"><TMPL_VAR name></a></h1>
    <p id="goto-content"><a href="#entry-wrap" title="Ir al contenido">Ir al Contenido</a></p>
    <div id="menu">
      <ul id="navbar">
[% instances_list %]
      </ul>
    </div><!--/menu-->
  </div><!--/inside-->
</div><!--/header-->

<div align="center">
<br /><br />
<script type="text/javascript"><!--
google_ad_client = "pub-1485276815879095";
/* planeta linux main header */
google_ad_slot = "4408550797";
google_ad_width = 728;
google_ad_height = 90;
//-->
</script>
<script type="text/javascript"
src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>
<br /><br />
</div>


<div id="entry-wrap">

<TMPL_LOOP Items>
	<TMPL_IF new_date>
	<h2 class="date"><TMPL_VAR new_date></h2>
	</TMPL_IF>

	<div class="entry">

	<TMPL_IF channel_portal>
	
		<a href="<TMPL_VAR channel_link>"><strong><TMPL_VAR channel_name></strong>: <a href="<TMPL_VAR link>"><TMPL_VAR title></a>
		  </div><!--/entry-->
	<TMPL_ELSE>
	

		<div class="author-info">
			<TMPL_IF channel_face><img class="cabeza" src="../images/cabezas/[% instance_code %]/<TMPL_VAR channel_face ESCAPE="HTML">" alt="<TMPL_VAR channel_name>" title="Hackergotchi de <TMPL_VAR channel_name>" /></TMPL_IF>
      	<div class="author-description"><p><span><TMPL_VAR channel_name></span><br />
      	<cite><a href="<TMPL_VAR channel_link ESCAPE="HTML">" title="Blog de: <TMPL_VAR channel_name>" class="weblog"><TMPL_VAR channel_title></a></cite>
      	<a href="<TMPL_VAR channel_url ESCAPE="HTML">" title="Feed de: <TMPL_VAR channel_title>" class="feed">feed</a>
		<TMPL_IF channel_twitter>
		<a href="http://twitter.com/<TMPL_VAR channel_twitter ESCAPE="HTML">" title="Twitter de: <TMPL_VAR channel_title>" class="twitter">twitter</a>
		</TMPL_IF>
		</p></div><!--/author-description-->
    	</div><!--/author-info-->
		<div class="post">
			<div class="post-inner">
				<h3 class="entry-title"><a href="<TMPL_VAR link ESCAPE="HTML">"><TMPL_IF title><TMPL_VAR title><TMPL_ELSE>(Sin Título)</TMPL_IF></a></h3>
				<div class="entry-content">

				<script type="text/javascript">
					tweetmeme_url = '<TMPL_VAR link ESCAPE="HTML">';
					tweetmeme_source = 'planetalinux';
				</script>

				<script type="text/javascript" src="http://tweetmeme.com/i/scripts/button.js"></script>
				<br />

				<TMPL_VAR content>
				
				</div><!--/entry-content-->
				<div class="post-footer">
      					<p><a href="<TMPL_VAR link ESCAPE="HTML">" class="permalink"><TMPL_VAR date></a></p>
				</div><!--post-footer-->
    			</div><!--/post-inner-->
		</div><!--/post-->
	  </div><!--/entry-->
	  
	  </TMPL_IF>

	
</TMPL_LOOP>
</div><!--entry-wrap-->

<div id="sidebar">

	<div id="first" class="inner">
		<h3 class="sidebartitle">Acerca</h3>
			<p>¡<em>Planeta Linux</em> es una comunidad de latinoamericanos blogueando sobre Linux!</p>
			<p>Si deseas conocer más sobre este proyecto, puedes informarte detalladamente <a href="http://www.planetalinux.org/faq.php">aquí</a>.</p>
	</div><!--/inner-->

	<div id="middle" class="inner">

	<h3 class="sidebartitle">Chat de Planeta Linux</h3>
	<p>Conéctate con otros usuarios y desarrolladores de software libre y Linux en el canal de chat de Planeta Linux: <a href="http://chat.planetalinux.org">chat.planetalinux.org</a>. También puedes usar tu cliente de IRC favorito, sólo apúntalo a <strong>#planetalinux</strong>, en <strong>irc.freenode.net</strong>: <a href="irc://irc.freenode.net/planetalinux">irc://irc.freenode.net/planetalinux</a>.</p>

	<h3 class="sidebartitle">Blog</h3>
	<p>Entérate de las noticias que suceden alrededor de Planeta Linux siguiendo nuestro <a href="http://blog.planetalinux.org">blog</a>.</p>
	
	<h3 class="sidebartitle">Twitter</h3>
	<p><a href="http://twitter.com/planetalinux">Sigue el Twitter de Planeta Linux.</a></p>

	<h3 class="sidebartitle">identi.ca</h3>
	<p>Actualizaciones de Planeta Linux también en <a href="http://identi.ca/planetalinux">identi.ca</a>.</p>


	<h3 class="sidebartitle">Last.FM</h3>
	<p>¿Qué música escuchamos en Planeta Linux? Únete al <a href="http://www.last.fm/group/Planeta_Linux">grupo de Planeta Linux</a> en <a href="http://last.fm/">Last.FM</a>.</p>

	<h3 class="sidebartitle">Facebook</h3>
	<p>También visita <a href="http://www.facebook.com/home.php#/pages/Planeta-Linux/10141091043">la página de Planeta Linux</a> en <a href="http://facebook.com">Facebook</a>.</p>

      	<h3 class="sidebartitle">Colabora</h3>
			<p>Si te interesa ser miembro de <em>Planeta Linux</em>, por favor,
			asegúrate de leer <a href="http://www.planetalinux.org/lineamientos.php">los lineamientos</a>
			para poder ser incluído y posteriormente 
			envía un correo a
			<a href="mailto:rt@rt.planetalinux.org">nuestro sistema de tickets</a> para que se te agregue.

			Cualquier persona, usuaria o desarrolladora de GNU/Linux o software libre, puede ser agregado.</p>
		  
		  
		  
		<h3 class="sidebartitle">Difunde</h3>
			<p>Ayúdanos a promocionar nuestro Planeta. Por favor, haz uso de estos <a href="http://www.planetalinux.org/banners.php" title="Botones de Planeta Linux">botones</a>.</p>

		<h3 class="sidebartitle">Gente</h3>
			<ul id="members">
			<TMPL_LOOP Channels>
				<TMPL_IF portal>
				<TMPL_ELSE>
					<li><a href="<TMPL_VAR link ESCAPE="HTML">" title="<TMPL_VAR title ESCAPE="HTML">"><TMPL_VAR name></a></li>
				</TMPL_IF>
			</TMPL_LOOP>
			</ul>
			<br />
			
		<h3 class="sidebartitle">Comunidades</h3>
			<ul id="members">
				<TMPL_LOOP Channels>
					<TMPL_IF portal>
						<li><a href="<TMPL_VAR link ESCAPE="HTML">" title="<TMPL_VAR title ESCAPE="HTML">"><TMPL_VAR name></a></li>
					<TMPL_ELSE>
					</TMPL_IF>
				</TMPL_LOOP>
			</ul>

		<br><br><br>

	<p><a href="http://astrata.com.mx">Astrata</a></p>

	</div><!--/inner-->

	<div id="last"></div>

	 
</div><!--/sidebar-->


<script type="text/javascript">
var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
</script>
<script type="text/javascript">
var pageTracker = _gat._getTracker("[% analytics_id %]");
pageTracker._trackPageview();
</script>

</body>
</html>
