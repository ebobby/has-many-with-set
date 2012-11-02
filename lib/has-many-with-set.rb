require "active_record"
require "active_support"

$LOAD_PATH.unshift(File.dirname(__FILE__))

require "has-many-with-set/has-many-with-set"
require "has-many-with-set/relationships"
require "has-many-with-set/queries"

module HasManyWithSet
end

if defined?(ActiveRecord::Base)
  ActiveRecord::Base.extend HasManyWithSet
end

$LOAD_PATH.shift
