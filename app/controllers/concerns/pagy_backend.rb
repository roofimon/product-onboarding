# Pagy Backend module for Rails controllers
module PagyBackend
  extend ActiveSupport::Concern

  included do
    # Ensure Pagy is loaded and Pagy::Method is available
    require "pagy" unless defined?(Pagy)
    require "pagy/toolbox/paginators/method" unless defined?(Pagy::Method)
    include Pagy::Method
  end
end
