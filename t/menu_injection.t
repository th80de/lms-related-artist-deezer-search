use strict;
use warnings;

use Test::More;

BEGIN {
	$INC{'Slim/Plugin/Base.pm'} = __FILE__;
	package Slim::Plugin::Base;
	our $VERSION = 1;
	sub initPlugin { return }

	$INC{'Slim/Menu/GlobalSearch.pm'} = __FILE__;
	package Slim::Menu::GlobalSearch;
	our %providers;
	sub registerInfoProvider {
		my ($class, $name, %provider) = @_;
		$providers{$name} = \%provider;
	}

	$INC{'Slim/Utils/Log.pm'} = __FILE__;
	package Slim::Utils::Log;
	sub logger { return bless {}, 'Slim::Utils::Log::TestLogger' }
	sub import {
		no strict 'refs';
		*{caller() . '::logger'} = \&logger;
	}
	package Slim::Utils::Log::TestLogger;
	sub info { return }
	sub warn { return }

	$INC{'Slim/Utils/PluginManager.pm'} = __FILE__;
	package Slim::Utils::PluginManager;
	sub isEnabled { return 1 }

	$INC{'Slim/Utils/Strings.pm'} = __FILE__;
	package Slim::Utils::Strings;
	sub import {
		no strict 'refs';
		*{caller() . '::cstring'} = \&cstring;
	}
	sub cstring { return $_[1] eq 'PLUGIN_RELATEDARTISTDEEZERSEARCH_DEEZER' ? 'Deezer' : $_[1] }

	package Plugins::Deezer::Plugin;
	sub search { return }
}

require './Plugin.pm';

Plugins::RelatedArtistDeezerSearch::Plugin->postinitPlugin();

ok($Slim::Menu::GlobalSearch::providers{relatedArtistDeezerSearch}, 'registers a global search provider');
is($Slim::Menu::GlobalSearch::providers{relatedArtistDeezerSearch}{after}, 'bottom', 'adds after existing search providers');

my $result = $Slim::Menu::GlobalSearch::providers{relatedArtistDeezerSearch}{func}->(
	undef,
	{ search => "Bjo\N{LATIN SMALL LETTER O WITH DIAERESIS}rk & Sigur R\N{LATIN SMALL LETTER O WITH ACUTE}s" },
);

is($result->{name}, 'Deezer', 'renders as the Deezer service in global search');
is($result->{type}, 'link', 'renders as a directly selectable service');
is($result->{passthrough}[0]{type}, 'artist', 'uses Deezer artist search');
is($result->{passthrough}[0]{query}, "Bjo\N{LATIN SMALL LETTER O WITH DIAERESIS}rk & Sigur R\N{LATIN SMALL LETTER O WITH ACUTE}s", 'preserves artist characters exactly');
is($result->{passthrough}[0]{strict}, 'on', 'uses strict Deezer matching');
ok(!defined $Slim::Menu::GlobalSearch::providers{relatedArtistDeezerSearch}{func}->(undef, { search => '' }), 'does not add an empty search item');

done_testing();
