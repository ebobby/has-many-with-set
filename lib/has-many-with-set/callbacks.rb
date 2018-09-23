module HasManyWithSet
  module Callbacks
    def self.build_saver_callback(set_table_name, set_items_table_name,
                                  child_table_name, instance_var_name)
      empty_set_query = Queries.build_find_empty_set_query(set_table_name, set_items_table_name)
      find_set_query = Queries.build_find_set_query(set_table_name, set_items_table_name, child_table_name)

      set_item_id_setter = "#{ set_table_name.singularize }_id=".to_sym
      set_items_setter   = "#{ child_table_name }=".to_sym

      klass = Object.const_get(set_table_name.classify)

      Proc.new do
        set = nil
        values = send(child_table_name)

        if values.blank?
          ActiveRecord::Base.transaction do
            set = klass.find_by_sql(empty_set_query).first

            if set.nil?
              set = klass.new
              set.save
            end
          end
        else
          values = values.flatten.uniq

          values.each do |v| v.save if v.changed? end

          ActiveRecord::Base.transaction do
            set = klass.find_by_sql([ find_set_query,
                                      values.map { |v| v.id },
                                      values.size,
                                      values.size ]).first
            if set.nil?
              set = klass.new
              set.send(set_items_setter, values)
              set.save
            end

            send(set_items_setter, values)
          end
        end

        send(set_item_id_setter, set.id)
      end
    end
  end
end
