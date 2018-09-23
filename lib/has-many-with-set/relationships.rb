module HasManyWithSet
  module Relationships
    def self.create_set_model(set_model_name)
      Object.const_set(set_model_name, Class.new(ApplicationRecord)) unless
        Object.const_defined?(set_model_name) # this *should* never happen...
    end

    def self.relate_child_to_set(set_model_name, child_model_name)
      # Take the child model and add a regular many-to-many relationship to the Set model...
      Object.const_get(child_model_name).class_eval do
        has_and_belongs_to_many set_model_name.tableize.to_sym, :join_table => "#{ set_model_name.tableize }_#{ child_model_name.tableize }"
      end

      # ... and take the Set model and finish the many-to-many relationship.
      Object.const_get(set_model_name).class_eval do
        has_and_belongs_to_many child_model_name.tableize.to_sym, :join_table => "#{ set_model_name.tableize }_#{ child_model_name.tableize }"
      end
    end

    def self.relate_parent_to_set(set_model_name, parent_model_name)
      # The parent object has a FK to the Set table, so it belongs_to it.
      Object.const_get(parent_model_name).class_eval do
        belongs_to set_model_name.tableize.singularize.to_sym, optional: true
      end
    end
  end
end
