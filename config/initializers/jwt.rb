# config/initializers/jwt.rb
require 'dotenv/load' # Ensure .env is loaded

Devise::JWT.configure do |config|
  config.dispatch_requests = [
    ['POST', %r{^/api/v1/login$}] # Only this path will dispatch JWTs upon successful Devise authentication
  ]
  config.revocation_requests = [
    ['DELETE', %r{^/api/v1/logout$}]
  ]
  config.expiration_time = 1.day.to_i # Adjust as needed
  config.secret = ENV['DEVISE_JWT_SECRET_KEY'] || Rails.application.credentials.devise_jwt_secret_key
end