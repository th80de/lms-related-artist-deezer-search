package Plugins::RelatedArtistDeezerSearch::Plugin;

use strict;
use warnings;

use base qw(Slim::Plugin::Base);

use Scalar::Util qw(refaddr);
use Slim::Utils::Log;
use Slim::Utils::PluginManager;
use Slim::Utils::Strings qw(cstring);

my $log = logger('plugin.relatedartistdeezersearch');

my $installed;
my $original_get_artist_menu;

sub initPlugin {

	my $class = shift;

	$class->SUPER::initPlugin(@_);
}

sub postinitPlugin {

	my $class = shift;

	return if $installed;

	if ( !Slim::Utils::PluginManager->isEnabled('Plugins::MusicArtistInfo::Plugin') ) {
		$log->warn('Music and Artist Information is not enabled; no menu integration was installed.');
		return;
	}

	if ( !Slim::Utils::PluginManager->isEnabled('Plugins::Deezer::Plugin') ) {
		$log->warn('Deezer is not enabled; no menu integration was installed.');
		return;
	}

	my $mai_class = 'Plugins::MusicArtistInfo::ArtistInfo';
	my $deezer_class = 'Plugins::Deezer::Plugin';
	my $original = $mai_class->can('getArtistMenu');
	my $search   = $deezer_class->can('search');

	if ( !$original || !$search ) {
		$log->warn('Required Music and Artist Information or Deezer API is unavailable; no menu integration was installed.');
		return;
	}

	$original_get_artist_menu = $original;

	# MAI does not expose a hook for its related-artist submenu. Wrap only this
	# function, preserving its signature and all items created by MAI or other
	# installed services.
	{
		no strict 'refs';
		no warnings 'redefine';
		*{'Plugins::MusicArtistInfo::ArtistInfo::getArtistMenu'} = sub {
		my ($client, $cb, $params, $args) = @_;

		if ($cb) {
			return $original_get_artist_menu->(
				$client,
				sub {
					my $items = shift;
					$class->_decorateMenu($client, $items, $params, $args);
					$cb->($items);
				},
				$params,
				$args,
			);
		}

		my $items = $original_get_artist_menu->(@_);
		return $class->_decorateMenu($client, $items, $params, $args);
		};
	}

	$installed = 1;
	$log->info('Installed Deezer related-artist menu integration.');
}

sub _decorateMenu {

	my ($class, $client, $items, $params, $args) = @_;

	# LMS callbacks receive { items => [...] }, whereas direct calls return the
	# array itself. Keep the original container for either calling convention.
	my $menu_items = ref $items eq 'HASH' ? $items->{items} : $items;
	return $items unless ref $menu_items eq 'ARRAY';

	my $artist = $class->_artistName($params, $args);
	return $items unless defined $artist && length $artist;

	# The MAI "Browse" item is already the correct local-library search for
	# related artists. Give it an explicit label instead of creating a duplicate.
	my $local_search = Plugins::MusicArtistInfo::ArtistInfo->can('_getSearchItem');
	if ($local_search) {
		foreach my $item (@$menu_items) {
			next unless ref $item eq 'HASH' && ref $item->{url} eq 'CODE';
			next unless refaddr($item->{url}) == refaddr($local_search);
			$item->{name} = cstring($client, 'PLUGIN_RELATEDARTISTDEEZERSEARCH_LOCAL_LIBRARY');
		}
	}

	# Avoid adding a second entry if LMS rebuilds and reuses a menu object.
	return $items if grep {
		ref $_ eq 'HASH' && ($_->{id} || '') eq 'relatedArtistDeezerSearch'
	} @$menu_items;

	my $deezer_search = Plugins::Deezer::Plugin->can('search');
	return $items unless $deezer_search;

	unshift @$menu_items, {
		id          => 'relatedArtistDeezerSearch',
		name        => cstring($client, 'PLUGIN_RELATEDARTISTDEEZERSEARCH_DEEZER_ARTIST'),
		type        => 'link',
		url         => $deezer_search,
		passthrough => [ {
			type   => 'artist',
			query  => $artist,
			strict => 'on',
		} ],
	};

	return $items;
}

sub _artistName {

	my ($class, $params, $args) = @_;

	for my $source ($args, $params) {
		next unless ref $source eq 'HASH';
		return $source->{artist} if defined $source->{artist} && length $source->{artist};
		return $source->{name}   if defined $source->{name}   && length $source->{name};
	}

	return;
}

1;
