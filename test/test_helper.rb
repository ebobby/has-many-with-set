require "active_record"
require "active_support"
require "rails"
require "rails/generators"
require "rails/test_help"

require File.expand_path("lib/has-many-with-set")
require "generators/has_many_with_set/migration_generator"

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
