source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.0"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.1.3", ">= 7.1.3.4"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 6.0"

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Use Tailwind CSS [https://github.com/rails/tailwindcss-rails]
gem "tailwindcss-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Sass to process CSS
# gem "sassc-rails"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]

end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
  
  gem "dockerfile-rails", ">= 1.6"

  # See https://github.com/bkeepers/dotenv
  gem 'dotenv-rails'

  # Deployment tool [https://github.com/basecamp/kamal]
  gem 'kamal', "~> 1.0.0"
end

# For LDAP integration [https://github.com/ruby-ldap/ruby-net-ldap]
gem 'net-ldap'

# pure-Ruby implementation of the SSH2 client protocol. Read more https://github.com/net-ssh/net-ssh
gem 'net-ssh', '~> 7.0'

# Rack Middleware for authentications [https://github.com/omniauth/omniauth]
gem "omniauth"
gem "omniauth-rails_csrf_protection"
# Omniauth OIDC provider [https://github.com/omniauth/omniauth_openid_connect]
gem "omniauth_openid_connect"

# Use simple Rails wrapper for Google Material Icons [https://github.com/Angelmmiguel/material_icons]
gem 'material_icons'

# Pagination [https://github.com/ddnexus/pagy]
gem "pagy", "~> 6.0"

# Object-based searching [https://github.com/activerecord-hackery/ransack]
gem "ransack", "~> 4.1"

# Redirect using POST method [https://github.com/vergilet/repost]
gem 'repost'

# A ruby implementation of the RFC 7519 OAuth JSON Web Token (JWT) standard [https://github.com/jwt/ruby-jwt]
gem 'jwt'

# Background processing. [https://github.com/sidekiq/sidekiq]
gem 'sidekiq', "~> 6.4"