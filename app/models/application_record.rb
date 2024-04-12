class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
  BASIC_ITEMS_NAME = ["water", "first aid"]
end
