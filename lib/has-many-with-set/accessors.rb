module HasManyWithSet
  module Accessors
    def self.build_loader_method(child_table_name, set_table_name)
      set_table_id = "#{ set_table_name.singularize }_id".to_sym
      set_table_name_singular = set_table_name.singularize.to_sym

      Proc.new do
        values = []

        values = send(set_table_name_singular).send(child_table_name).to_a unless
          send(set_table_id).nil?

        values
      end
    end

    def self.build_getter_method(instance_var_name, loader_method_name)
      Proc.new do
        unless instance_variable_defined?(instance_var_name)
          values = send(loader_method_name.to_sym)
          instance_variable_set(instance_var_name, values)
        end

        instance_variable_get(instance_var_name)
      end
    end

    def self.build_setter_method(instance_var_name)
      Proc.new do |elements|
        elements = [] if elements.nil?

        unless elements.is_a? Array
          if elements.respond_to?(:is_a)
            elements = elements.to_a
          else
            elements = [ elements ]
          end
        end

        elements = elements.flatten.uniq

        instance_variable_set(instance_var_name, elements)
      end
    end

    def self.build_parent_loader_method(parent_table_name, child_table_name, set_table_name, set_items_table_name)
      find_query = Queries.build_find_parents_query(parent_table_name, child_table_name, set_table_name, set_items_table_name)

      parent_klass = Object.const_get(parent_table_name.classify)

      Proc.new {
        values = []
        values = parent_klass.find_by_sql([ find_query, self ]).to_a
        values
      }
    end
  end
end
