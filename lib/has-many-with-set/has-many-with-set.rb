module HasManyWithSet
  # Add the has_many_with_set relationship type to ActiveRecord.
  def has_many_with_set (child)
    # Article, Tags
    build_set_relationship self.to_s, child.to_s.classify
  end

  private

  def build_set_relationship (parent_model_name, child_model_name)
    extend HasManyWithSet::Relationships

    create_set_model child_model_name
    relate_child_to_set child_model_name
    relate_parent_to_set parent_model_name, child_model_name
  end
end
