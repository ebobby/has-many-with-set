require 'rails/generators'

module HasManyWithSet
  class MigrationGenerator < Rails::Generators::Base
    include Rails::Generators::Migration
    source_root File.expand_path('../templates', __FILE__)

    def self.next_migration_number(path)
      Time.now.utc.strftime("%Y%m%d%H%M%S")
    end

    ORM_IDENTIFIER_SIZE_LIMIT = 63

    argument :parent, :type => :string, :required => true
    argument :child, :type => :string, :required => true

    attr_accessor :parent, :child

    desc "This generates the migration file needed for a has_many_with_set relationship."
    def create_migration
      @parent_table = parent.tableize
      @child_table = child.tableize
      @set_table = "#{ @parent_table }_#{ @child_table }_sets"
      @set_items_table = "#{ @set_table }_#{ @child_table }"
      @migration_class_name = "create_#{ @set_table }".classify
      @items_table_set_table_index = "ix_items_#{ @set_items_table }"[0,  ORM_IDENTIFIER_SIZE_LIMIT]
      @items_table_child_table_index = "ix_#{ @child_table }_#{ @set_items_table }"[0,  ORM_IDENTIFIER_SIZE_LIMIT]

      migration_template "sets.rb.erb", "db/migrate/#{ @migration_class_name.tableize.singularize }.rb"
    end
  end
end
