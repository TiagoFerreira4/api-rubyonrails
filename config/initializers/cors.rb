# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*' # Or specify your frontend domain in production

    resource '*',
      headers: :any,
      expose: ['access-token', 'expiry', 'token-type', 'Authorization'], # Expose Authorization for JWT
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end