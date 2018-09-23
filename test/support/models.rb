class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end

class Two < ApplicationRecord
end

class One < ApplicationRecord
  has_many_with_set :two
end
