source 'https://rubygems.org'

ruby '2.2.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.9'


# for Heroku deployment - as described in Ap. A of ELLS book
group :development, :test do
	gem 'sqlite3'
  gem 'cucumber-rails', :require => false
  gem 'cucumber-rails-training-wheels'
  gem 'database_cleaner'
  gem 'capybara'
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'simplecov'
  gem 'pry'
  gem 'rubocop'
end

group :production do
	gem 'pg'
  gem 'rails_12factor'
end

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

gem 'coffee-rails', '~> 4.0.0'
gem 'uglifier', '>= 1.3.0'
gem 'sass-rails', '~> 4.0.0'
gem 'bootstrap-sass', '~> 3.3.3'

gem 'jquery-rails'
gem 'turbolinks'							# makes following links faster
gem 'jbuilder', '~> 1.2'			# Build JSON APIs with ease.

gem 'sprockets-rails', :require => 'sprockets/railtie' # provides sprockets implementation for rails 4 asset pipeline
gem 'autoprefixer-rails'      # automatically adds the proper vendor prefixes to your CSS code when it is compiled
gem 'twitter'                 # ruby interface to the twitter API.
gem 'figaro'                  # allows secure configuration using ENV vars in a yml file

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.1.2'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]
