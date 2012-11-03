module HasManyWithSet
  # This is the magic entry point method that adds set relationships to a model.
  def has_many_with_set (child)
    build_set_relationship self.to_s, child.to_s.classify
  end

  private

  def build_set_relationship (parent_model_name, child_model_name)
    extend HasManyWithSet::Relationships

    set_model_name = create_set_model(child_model_name)

    child_table_name     = child_model_name.tableize
    set_table_name       = set_model_name.tableize
    set_items_table_name = "#{ set_table_name }_#{ child_table_name }"

    relate_child_to_set(child_model_name)
    relate_parent_to_set(parent_model_name, child_model_name)

    define_method(child_table_name, Accessors.build_getter_method(child_table_name, set_table_name))
    define_method("#{ child_table_name }=", Accessors.build_setter_method(child_table_name))
  end
end
