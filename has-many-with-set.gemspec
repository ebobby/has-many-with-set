$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "has-many-with-set/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "has-many-with-set"
  s.version     = HasManyWithSet::VERSION
  s.authors     = ["Francisco Soto"]
  s.email       = ["ebobby@ebobby.org"]
  s.homepage    = "https://github.com/ebobby/has-many-with-set"
  s.summary     = "A smarter way of doing many-to-many relationships in Rails."
  s.description = "A smarter way of doing many-to-many relationships in Rails."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.textile", "CHANGELOG" ]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 5"
  s.add_development_dependency "sqlite3"
end
