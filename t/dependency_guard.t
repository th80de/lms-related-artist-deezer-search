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
	our $registrations = 0;
	sub registerInfoProvider { $registrations++ }

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
	sub isEnabled {
		my ($class, $plugin) = @_;
		return $plugin ne 'Plugins::Deezer::Plugin';
	}

	$INC{'Slim/Utils/Strings.pm'} = __FILE__;
	package Slim::Utils::Strings;
	sub import { return }

	package Plugins::Deezer::Plugin;
	sub search { return }
}

require './Plugin.pm';

Plugins::RelatedArtistDeezerSearch::Plugin->postinitPlugin();

is($Slim::Menu::GlobalSearch::registrations, 0, 'does not register when Deezer is disabled');

done_testing();
