class Item < ApplicationRecord
	attr_accessor :cache_selling_quantity
	belongs_to :survivor
  scope :essentials, -> { where("lower(item) IN (?) AND quantity <= ?", BASIC_ITEMS_NAME, 0) } 
end
