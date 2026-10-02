package Plugins::RelatedArtistDeezerSearch::Plugin;

use strict;
use warnings;

use base qw(Slim::Plugin::Base);

use Slim::Menu::GlobalSearch;
use Slim::Utils::Log;
use Slim::Utils::PluginManager;
use Slim::Utils::Strings qw(cstring);

my $log = logger('plugin.relatedartistdeezersearch');

my $registered;

sub initPlugin {

	my $class = shift;

	$class->SUPER::initPlugin(@_);

	return if $registered;

	if ( !Slim::Utils::PluginManager->isEnabled('Plugins::Deezer::Plugin') ) {
		$log->warn('Deezer is not enabled; no global-search integration was registered.');
		return;
	}

	# Material Skin follows links in MAI's “Ähnliche Interpreten” section with
	# nowplayingSearch(). That opens Slim::Menu::GlobalSearch directly, bypassing
	# MAI's getArtistMenu(). GlobalSearch providers must be registered from
	# initPlugin(), as done by Bandcamp and Qobuz; postinitPlugin() is too late
	# for the provider list used by LMS 9.1.
	Slim::Menu::GlobalSearch->registerInfoProvider(
		relatedArtistDeezerSearch => (
			after => 'bottom',
			func  => \&searchHandler,
		)
	);

	$registered = 1;
	$log->info('Registered Deezer in LMS global search.');
}

sub searchHandler {

	my ($client, $tags) = @_;

	my $query = $tags && $tags->{search};
	return unless defined $query && length $query;

	# A GlobalSearch provider represents a service. Returning an array with a
	# named service makes Material Skin add it to “Suche auf …”, consistent with
	# Bandcamp and BBC Sounds. The only child is a strict Deezer artist search.
	return [ {
		name  => cstring($client, 'PLUGIN_RELATEDARTISTDEEZERSEARCH_DEEZER'),
		items => [ {
			name        => cstring($client, 'PLUGIN_RELATEDARTISTDEEZERSEARCH_SEARCH_ARTIST'),
			type        => 'link',
			url         => \&searchArtist,
			passthrough => [ { query => $query } ],
		} ],
	} ];
}

sub searchArtist {

	my ($client, $cb, $args, $params) = @_;

	return $cb->({ items => [] }) unless Plugins::Deezer::Plugin->can('search');

	$args   ||= {};
	$params ||= {};

	# Deezer's existing handler reads query/type/strict from $params, not from
	# the menu item's passthrough hash. Copy the original artist spelling across
	# unchanged and force its narrowest search mode.
	$params->{query}  = $args->{query} if defined $args->{query};
	$params->{type}   = 'artist';
	$params->{strict} = 'on';

	return Plugins::Deezer::Plugin::search($client, $cb, $args, $params);
}

1;
