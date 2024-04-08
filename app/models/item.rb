class Item < ApplicationRecord
	belongs_to :survivor

	def is_item_valid?(str)
		item.include?(str)
	end
end
