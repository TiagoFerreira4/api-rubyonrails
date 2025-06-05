require_relative "boot"

require "rails/all"


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


    config.api_only = false # Set to true initially, but we add back for mini-frontend and Devise views


    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore, key: '_digital_library_session'
    config.middleware.use Rack::MethodOverride
    config.middleware.use ActionDispatch::Flash



    config.autoload_paths += %W(#{config.root}/app/services #{config.root}/app/policies #{config.root}/app/blueprints #{config.root}/app/graphql #{config.root}/app/graphql/types #{config.root}/app/graphql/mutations)

    # For GraphQL Playground
    #config.middleware.use GraphQL::Playground::Rails::Middleware, endpoint: '/api/v1/graphql'
  end
end