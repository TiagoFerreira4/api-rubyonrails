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

  # API specific routes
  namespace :api do
    namespace :v1 do
      # Devise routes for JWT authentication
      devise_scope :user do
        post 'login', to: 'sessions#create', defaults: { format: :json }
        delete 'logout', to: 'sessions#destroy', defaults: { format: :json }
        post 'signup', to: 'users#create', defaults: { format: :json }
      end


      resources :authors, defaults: { format: :json }
      resources :materials, defaults: { format: :json } do
        collection do
          get :search
        end
      end

    end
  end


  root 'frontend#index'
  get '/frontend/new_material', to: 'frontend#new_material', as: 'new_frontend_material'
  post '/frontend/create_material', to: 'frontend#create_material', as: 'create_frontend_material'


end