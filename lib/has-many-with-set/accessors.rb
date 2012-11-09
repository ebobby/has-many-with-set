module HasManyWithSet
  module Accessors
    def self.build_loader_method (child_table_name, set_table_name)
      set_table_id = "#{ set_table_name.singularize }_id"
      set_table_name_singular = set_table_name.singularize

      Proc.new {
        values = []
        values = send(set_table_name_singular).send(child_table_name).to_a unless send(set_table_id).nil?
        values
      }
    end

    def self.build_getter_method (instance_var_name, loader_method_name)
      Proc.new {
        values = instance_variable_get(instance_var_name)

        unless values
          values = send(loader_method_name)
          instance_variable_set(instance_var_name, values)
        end

        values
      }
    end

    def self.build_setter_method (instance_var_name)
      Proc.new { |elements|
        elements = [] if elements.nil?

        unless elements.is_a? Array
          if elements.respond_to?(:is_a)
            elements = elements.to_a
          else
            elements = [ elements ]
          end
        end

        elements.flatten!

        instance_variable_set(instance_var_name, elements)
      }
    end
  end
end
