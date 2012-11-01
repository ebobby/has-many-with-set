require 'rails/generators'

module HasManyWithSet
  class MigrationGenerator < Rails::Generators::Base
    include Rails::Generators::Migration
    source_root File.expand_path('../templates', __FILE__)

    def self.next_migration_number(path)
      Time.now.utc.strftime("%Y%m%d%H%M%S")
    end

    argument :parent, :type => :string, :required => true
    argument :child, :type => :string, :required => true

    attr_accessor :parent, :child

    desc "This generates the migration file needed for a has_many_with_set relationship."
    def create_migration
      self.parent = parent
      self.child = child

      migration_template "sets.rb.erb", "db/migrate/create_#{ child.tableize.singularize }_set.rb"
    end
  end
end
