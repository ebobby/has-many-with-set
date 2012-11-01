module HasManyWithSet
  # Add the has_many_with_set relationship type to ActiveRecord.
  def has_many_with_set (parent, child)
    build_set_relationship parent, child
  end

  private

  def build_set_relationship (parent, child)
    extend HasManyWithSet::Relationships

    create_set_model(child)
    relate_child_to_set(child)
    relate_parent_to_set(parent, child)
  end
end
