require "active_record"
require "active_support"
require "rails"
require "rails/generators"
require "rails/test_help"

# Need this to test the generator
require "generators/has_many_with_set/migration_generator"

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
