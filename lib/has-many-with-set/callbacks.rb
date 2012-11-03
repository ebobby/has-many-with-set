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

    def self.build_saver_callback (set_table_name, set_items_table_name,
                                   child_table_name, instance_var_name)
      empty_set_query = Queries.build_find_empty_set_query(set_table_name, set_items_table_name)
      find_set_query = Queries.build_find_set_query(set_table_name, set_items_table_name, child_table_name)

      set_item_id_setter = "#{ set_table_name.singularize }_id="
      set_items_setter   = "#{ child_table_name }="

      klass = Object.const_get(set_table_name.classify)

      Proc.new {
        set = nil
        values = instance_variable_get(instance_var_name)

        if values.empty?
          set = klass.find_by_sql(empty_set_query).first

          if set.nil?
            set = klass.new
            set.save
          end
        else
          values.each do |v| v.save if v.changed? end

          set = klass.find_by_sql([ find_set_query,
                                    values.map { |v| v.id },
                                    values.size,
                                    values.size ]).first
          if set.nil?
            set = klass.new
            set.send(set_items_setter, values)
            set.save
          end
        end

        send(set_item_id_setter, set.id)
      }
    end
  end
end
