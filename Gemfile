# frozen_string_literal: true

source 'https://rubygems.org'

# Force git gems to use secure HTTPS
git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

# All the gems not in a group will always be installed:
#   http://bundler.io/v1.6/groups.html#grouping-your-dependencies

gem 'bulk_insert'
gem 'cancancan'
gem 'faraday'
gem 'jsonapi-resources'
gem 'lograge'
gem 'logstash-event'
gem 'logstash-logger'
gem 'pg', '~> 0.18'
gem 'pry'
gem 'puma', '~> 3.0'
gem 'rails', '~> 5.0.0', '>= 5.0.0.1'
gem 'request_store'
gem 'rswag-api'
gem 'rswag-ui'
gem 'sprockets-rails'
gem 'swagger-ui_rails'

###
# Sanger gems
###
gem 'aker_credentials_gem', github: 'sanger/aker-credentials'

###
# Groups
###
group :test, :development do
  gem 'brakeman', require: false
  gem 'byebug', platform: :mri
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'json-schema'
  gem 'jwt'
  gem 'rspec-rails'
  gem 'rswag-specs'
end

group :development do
  gem 'listen', '~> 3.0.5'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'rake'
  gem 'rubycritic'
  gem 'simplecov', require: false
  gem 'simplecov-rcov'
end
