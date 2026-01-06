ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.
require 'logger' # Explicitly require Logger before ActiveSupport

# Load environment variables from .env file (only in development/test)
require 'dotenv/load' if ['development', 'test'].include?(ENV['RAILS_ENV'] || 'development')

# require "bootsnap/setup" # Speed up boot time by caching expensive operations.
