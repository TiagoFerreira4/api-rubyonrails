Rails.application.routes.draw do
  devise_for :users
  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
  end
  post "/graphql", to: "graphql#execute"
  # RSwag API/UI Engine
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  # GraphQL Endpoint
  #if Rails.env.development? || Rails.env.test? # Keep Playground for dev/test
  #  mount GraphQL::Playground::Rails::Engine, at: "/api/v1/graphql_playground", graphql_path: "/api/v1/graphql"
  #end
  post "/api/v1/graphql", to: "graphql#execute" # Main GraphQL endpoint

  # API specific routes (versioned)
  namespace :api do
    namespace :v1 do
      # Devise routes for JWT authentication
      devise_scope :user do
        post 'login', to: 'sessions#create', defaults: { format: :json }
        delete 'logout', to: 'sessions#destroy', defaults: { format: :json }
        post 'signup', to: 'users#create', defaults: { format: :json }
      end
      # We don't use devise_for :users here directly under api/v1 to avoid HTML routes.
      # The above scope customizes the paths for JSON API.

      resources :authors, defaults: { format: :json }
      resources :materials, defaults: { format: :json } do
        collection do
          get :search #  /api/v1/materials/search?term=...
        end
      end
      # If you want separate routes for Books, Articles, Videos (e.g., for specific non-polymorphic actions)
      # resources :books, controller: 'materials', type: 'Book', defaults: { format: :json }
      # resources :articles, controller: 'materials', type: 'Article', defaults: { format: :json }
      # resources :videos, controller: 'materials', type: 'Video', defaults: { format: :json }
    end
  end

  # Mini Frontend (Non-API routes)
  # This must be outside api_only block or api_only must be false.
  # If config.api_only = true was set and you need HTML views:
  # 1. Set config.api_only = false in application.rb
  # 2. Ensure ApplicationController inherits from ActionController::Base
  #    and Api::V1::BaseController inherits from ActionController::API
  # For this project, we modified application.rb to re-include middleware.

  # Ensure the root path or other frontend paths are defined
  root 'frontend#index' # Example root for the mini-frontend
  get '/frontend/new_material', to: 'frontend#new_material', as: 'new_frontend_material'
  post '/frontend/create_material', to: 'frontend#create_material', as: 'create_frontend_material'

  # Devise for Users (HTML views for password recovery, etc., if needed, otherwise covered by API)
  # If you want HTML views for devise (e.g. for forgot password page for the frontend)
  # devise_for :users, skip: [:sessions, :registrations] # Skip API handled ones
  # As we are API focused and signup/login is handled via API,
  # standard devise_for might not be needed unless for password reset emails through HTML flow.
  # For this project, we will assume password reset can also be initiated/handled via API tokens if built.
  # The prompt doesn't explicitly ask for HTML password reset flow.
end