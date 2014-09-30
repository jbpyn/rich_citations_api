class Base < ActiveRecord::Base
  self.abstract_class = true

  extend JsonAttributes
end