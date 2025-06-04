require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module DigitalLibraryApi
  class Application < Rails::Application
    config.active_record.query_log_tags_enabled = true
    config.active_record.query_log_tags = [
      # Rails query log tags:
      :application, :controller, :action, :job,
      # GraphQL-Ruby query log tags:
      current_graphql_operation: -> { GraphQL::Current.operation_name },
      current_graphql_field: -> { GraphQL::Current.field&.path },
      current_dataloader_source: -> { GraphQL::Current.dataloader_source_class },
    ]
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = false # Set to true initially, but we add back for mini-frontend and Devise views

    # We need session store for Devise and potentially the mini-frontend
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore, key: '_digital_library_session'
    config.middleware.use Rack::MethodOverride
    config.middleware.use ActionDispatch::Flash


    # Autoload paths for services, policies, blueprints, etc.
    config.autoload_paths += %W(#{config.root}/app/services #{config.root}/app/policies #{config.root}/app/blueprints #{config.root}/app/graphql #{config.root}/app/graphql/types #{config.root}/app/graphql/mutations)

    # For GraphQL Playground
    #config.middleware.use GraphQL::Playground::Rails::Middleware, endpoint: '/api/v1/graphql'
  end
end