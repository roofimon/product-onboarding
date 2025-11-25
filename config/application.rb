require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ProductOnboarding
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Modular Monolith: Autoload domain paths
    %w[authentication admin products profiles public].each do |domain|
      config.autoload_paths << Rails.root.join("app/domains/#{domain}/controllers")
      config.autoload_paths << Rails.root.join("app/domains/#{domain}/models")
    end

    # Add domain view paths
    config.paths["app/views"].unshift(
      Rails.root.join("app/domains/authentication/views"),
      Rails.root.join("app/domains/admin/views"),
      Rails.root.join("app/domains/products/views"),
      Rails.root.join("app/domains/profiles/views"),
      Rails.root.join("app/domains/public/views")
    )
  end
end
