# Pagy configuration
# See https://github.com/ddnexus/pagy/blob/master/lib/config/pagy.rb for available options

require "pagy"

# Configure Pagy defaults
# Note: Pagy::DEFAULT is frozen, so we configure via Pagy::DEFAULT_FREEZE
# The default items per page will be set in the controller when calling pagy()
