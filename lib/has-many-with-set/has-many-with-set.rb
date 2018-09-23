module HasManyWithSet
  # This is the magic entry point method that adds set relationships to a model.
  def has_many_with_set(child)
    build_set_relationship self.to_s, child.to_s.classify
  end

  private

  def build_set_relationship(parent_model_name, child_model_name)
    parent_table_name               = parent_model_name.tableize
    child_table_name                = child_model_name.tableize
    set_table_name                  = "#{ parent_table_name }_#{ child_table_name }_sets"
    set_model_name                  = set_table_name.classify
    set_items_table_name            = "#{ set_table_name }_#{ child_table_name }"
    instance_var_name               = "@#{ child_table_name }"
    child_instance_var_name         = "@#{ parent_table_name }"
    setter_method_name              = "#{ child_table_name }="
    loader_method_name              = "#{ set_items_table_name }_loader"
    parent_loader_method_name       = "#{ parent_table_name }_loader"
    save_callback_method_name       = "#{ set_items_table_name }_save_callback"
    child_klass                     = Object.const_get(child_model_name)

    Relationships.create_set_model(set_model_name)
    Relationships.relate_child_to_set(set_model_name, child_model_name)
    Relationships.relate_parent_to_set(set_model_name, parent_model_name)

    # Parent methods
    define_method(loader_method_name,
                  Accessors.build_loader_method(child_table_name, set_table_name))

    define_method(child_table_name,
                  Accessors.build_getter_method(instance_var_name, loader_method_name))

    define_method(setter_method_name,
                  Accessors.build_setter_method(instance_var_name))

    define_method(save_callback_method_name,
                  Callbacks.build_saver_callback(set_table_name, set_items_table_name,
                                                 child_table_name, instance_var_name))

    # Child methods
    child_klass.send(:define_method, parent_loader_method_name,
                     Accessors.build_parent_loader_method(parent_table_name, child_table_name,
                                                          set_table_name, set_items_table_name))

    child_klass.send(:define_method, parent_table_name,
                     Accessors.build_getter_method(child_instance_var_name, parent_loader_method_name))

    child_klass.send(:private, parent_loader_method_name)

    class_eval do
      private loader_method_name
      private save_callback_method_name

      before_save save_callback_method_name.to_sym
    end
  end
end
