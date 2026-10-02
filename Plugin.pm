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
}

sub postinitPlugin {

	my $class = shift;

	return if $registered;

	if ( !Slim::Utils::PluginManager->isEnabled('Plugins::Deezer::Plugin') ) {
		$log->warn('Deezer is not enabled; no global-search integration was registered.');
		return;
	}

	if ( !Plugins::Deezer::Plugin->can('search') ) {
		$log->warn('The Deezer search API is unavailable; no global-search integration was registered.');
		return;
	}

	# Material Skin follows links in MAI's “Ähnliche Interpreten” section with
	# nowplayingSearch(). That opens Slim::Menu::GlobalSearch directly, bypassing
	# MAI's getArtistMenu(). Registering here places Deezer beside Bandcamp and
	# BBC Sounds in that exact “Suche auf …” section.
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

	my $deezer_search = Plugins::Deezer::Plugin->can('search');
	return unless $deezer_search;

	return {
		name        => cstring($client, 'PLUGIN_RELATEDARTISTDEEZERSEARCH_DEEZER'),
		type        => 'link',
		url         => $deezer_search,
		passthrough => [ {
			type   => 'artist',
			query  => $query,
			strict => 'on',
		} ],
	};
}

1;
