module HasManyWithSet
  module Callbacks
    def self.build_loader_callback (instance_var_name, child_table_name, set_table_name)
      set_table_id = "#{ set_table_name.singularize }_id"

      Proc.new {
        value = []
        value = send(set_table_name.singularize).send(child_table_name).to_a unless send(set_table_id).nil?

        instance_variable_set(instance_var_name, value)
      }
    end
  end
end
