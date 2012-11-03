module HasManyWithSet
  module Accessors
    def self.build_getter_method (child_table_name, set_table_name)
      local_var_name = "@#{ child_table_name }"             # These are kept in a closure so they are
      set_table_id   = "#{ set_table_name.singularize }_id" # evaluated only once and reused.

      Proc.new {
        unless instance_variable_get(local_var_name)
          value = []
          value = send(set_table_name.singularize).send(child_table_name).to_a unless send(set_table_id).nil?

          instance_variable_set(local_var_name, value)
        end

        instance_variable_get(local_var_name)
      }
    end

    def self.build_setter_method (child_table_name)
      local_var_name = "@#{ child_table_name }"

      Proc.new { |*elements|
        instance_variable_set(local_var_name, elements)
      }
    end
  end
end
