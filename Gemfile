source 'https://rubygems.org'
git_source(:github) { |repo_name| "https://github.com/#{repo_name}.git" }

ruby '3.2.8' # Mantendo a versão do seu ambiente

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 7.1.5' # ATUALIZADO para a última patch da série 7.1.x estável

# Server
gem 'puma', '~> 6.4' # Mantendo a versão compatível com Rails 7.1

# Database
gem 'pg', '~> 1.5'

# API Specific
gem 'jbuilder', '~> 2.11'
gem 'blueprinter', '~> 1.1.2' # Se persistir o problema, fixar em '2.1.2' ou similar.
gem 'kaminari', '~> 1.2', '>= 1.2.2'

# Authentication
gem 'devise', '~> 4.9'
gem 'devise-jwt', '~> 0.10.0'

# Authorization
gem 'pundit', '~> 2.3'

# GraphQL
gem 'graphql', '~> 2.0'
# gem 'graphql-playground-rails', '~> 1.2.1' # REMOVIDO/COMENTADO conforme decisão

# API Documentation (Swagger/OpenAPI)
gem 'rswag-api', '~> 2.8'
gem 'rswag-ui', '~> 2.8'
gem 'rswag-specs', '~> 2.8'

# HTTP Client for External API
gem 'httparty', '~> 0.21.0'

# Background Jobs (Optional, but good for external API calls if they are slow)
# gem 'sidekiq'

# Code Quality & Linters
gem 'rubocop', require: false
gem 'rubocop-rails', require: false
gem 'rubocop-performance', require: false
gem 'rubocop-rspec', require: false

# Environment Variables
gem 'dotenv-rails', groups: [:development, :test]

group :development, :test do
  gem 'rspec-rails', '~> 6.0'
  gem 'factory_bot_rails', '~> 6.2'
  gem 'faker', '~> 3.2'
  gem 'shoulda-matchers', '~> 5.3'
  gem 'simplecov', require: false
  gem 'database_cleaner-active_record'
  # gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # gem 'pry-rails'
end

group :development do
  gem 'web-console', '>= 4.2.0'
  gem 'bootsnap', '>= 1.16.0', require: false
  # gem 'annotate', '~> 3.2'
end

group :test do
  gem 'webmock', '~> 3.18'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]


gem 'rack-cors'
gem "graphiql-rails", group: :development
