module HasManyWithSet
  module Relationships
    def create_set_model (child)
      set_model_name = generate_set_model_name(symbol_to_class_name(child))

      Object.const_set(set_model_name, Class.new(ActiveRecord::Base)) unless
        Object.const_defined?(set_model_name) # this *should* never happen...
    end

    def relate_child_to_set (child)
      child_model_name = symbol_to_class_name(child)
      set_model_name = generate_set_model_name(child_model_name)

      # Take the child model and add a regular many-to-many relationship to the Set model...
      Object.const_get(child_model_name).class_eval do
        has_and_belongs_to_many set_model_name.tableize.to_sym
      end

      # ... and take the Set model and finish the many-to-many relationship.
      Object.const_get(set_model_name).class_eval do
        has_and_belongs_to_many child_model_name.tableize.to_sym
      end
    end

    def relate_parent_to_set (parent, child)
      parent_model_name = symbol_to_class_name(parent)
      child_model_name = symbol_to_class_name(child)

      # The parent object has a FK to the Set table, so it belongs_to it.
      Object.const_get(parent_model_name).class_eval do
        belongs_to generate_set_model_name(child_model_name).tableize.singularize.to_sym
      end
    end

    private

    def symbol_to_class_name (symbol)
      symbol.to_s.classify
    end

    # Generates a name for Set models based on the child table name.
    def generate_set_model_name (target_model)
      "#{ target_model }Set".classify
    end
  end
end
