class ModelTwo < ActiveRecord::Base
end

class ModelOne < ActiveRecord::Base
  has_many_with_set :model_two
end
