use strict;
use warnings;

use Test::More;

BEGIN {
	$INC{'Slim/Plugin/Base.pm'} = __FILE__;
	package Slim::Plugin::Base;
	our $VERSION = 1;
	sub initPlugin { return }

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
	sub cstring {
		my ($client, $token) = @_;
		return {
			PLUGIN_RELATEDARTISTDEEZERSEARCH_DEEZER_ARTIST => 'Deezer: Search artist',
			PLUGIN_RELATEDARTISTDEEZERSEARCH_LOCAL_LIBRARY => 'Search local library',
		}->{$token} || $token;
	}

	package Plugins::MusicArtistInfo::ArtistInfo;
	sub _getSearchItem { return }
	sub getArtistMenu {
		my ($client, $cb) = @_;
		my $items = [
			{ name => 'Bandcamp', type => 'link' },
			{ name => 'Browse', type => 'link', url => \&_getSearchItem },
			{ name => 'BBC Sounds', type => 'link' },
		];
		return $cb->({ items => $items }) if $cb;
		return $items;
	}

	package Plugins::Deezer::Plugin;
	sub search { return }
}

require './Plugin.pm';

Plugins::RelatedArtistDeezerSearch::Plugin->postinitPlugin();

my $items = Plugins::MusicArtistInfo::ArtistInfo::getArtistMenu(
	undef, undef, { name => "Bjo\N{LATIN SMALL LETTER O WITH DIAERESIS}rk & Sigur R\N{LATIN SMALL LETTER O WITH ACUTE}s" }, undef,
);

is($items->[0]{id}, 'relatedArtistDeezerSearch', 'adds a marked Deezer item first');
is($items->[0]{passthrough}[0]{type}, 'artist', 'uses Deezer artist search');
is($items->[0]{passthrough}[0]{query}, "Bjo\N{LATIN SMALL LETTER O WITH DIAERESIS}rk & Sigur R\N{LATIN SMALL LETTER O WITH ACUTE}s", 'preserves artist characters exactly');
is($items->[0]{passthrough}[0]{strict}, 'on', 'uses strict Deezer matching');
is($items->[2]{name}, 'Search local library', 'renames the MAI local Browse action');
is_deeply([ map { $_->{name} } @$items[1, 3] ], ['Bandcamp', 'BBC Sounds'], 'preserves external actions');

my $callback_items;
Plugins::MusicArtistInfo::ArtistInfo::getArtistMenu(
	undef,
	sub { $callback_items = shift },
	{ artist => 'Kraftwerk' },
	undef,
);
is($callback_items->{items}[0]{passthrough}[0]{query}, 'Kraftwerk', 'supports callback-style menu building');

is(
	scalar(grep { ($_->{id} || '') eq 'relatedArtistDeezerSearch' } @{$callback_items->{items}}),
	1,
	'does not duplicate the Deezer item',
);

done_testing();
