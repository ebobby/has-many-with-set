class ModelTwo < ActiveRecord::Base
end

class ModelOne < ActiveRecord::Base
  attr_accessible :num
  has_many_with_set :model_two
end
