class Item < ApplicationRecord
	belongs_to :survivor

	def is_item_valid?(str)
		item.include?(str)
	end

	def self.update_quantity(items, survivor1, survivor2)
	  items.each do |item|
	    item = survivor1.items.find_or_initialize_by(item: item_params[:item])
	    item.quantity += item_params[:quantity]
	    item.points ||= item_params[:points]
	    item.save!

	    res = survivor2.items.find_by(item: item_params[:item])
	    if res.presen?
				res.quantity -= item_params[:quantity]
				res.quantity <= 0 ? res.destroy : res.save!		
			end
	  end
	end


	# def self.update_item(items, survivor)
	# 	items.each do |obj|
	# 		res = survivor2.items.find_by(item: obj[:item])
	# 		res.quantity -= obj[:quantity]
	# 		res.save
	# 	end
	# end
end
