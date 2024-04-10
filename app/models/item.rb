class Item < ApplicationRecord
	belongs_to :survivor

	def is_item_valid?(str)
		item.include?(str)
	end

	def self.send_item_detail(receiver_items, receiver, sender, sender_items)
	  update_item(receiver_items, receiver, sender)
	  update_item(sender_items, sender, receiver)
	end

 private

	def self.update_item(items, survivor1, survivor2)
		items.each do |item_params|
	    item = survivor1.items.find_or_initialize_by(item: item_params[:item])
	   	item.quantity = item.quantity? ? item.quantity + item_params[:quantity] : item_params[:quantity]
	    item.points ||= Item.find_by(item: item_params[:item]).points
	    item.save!

	    res = survivor2.items.find_by(item: item_params[:item])
			res.quantity -= item_params[:quantity]
			res.quantity <= 0 ? res.destroy : res.save!	
			if res.item == "water" || res.item == "first aid"
			  res.quantity <= 0 ? survivor2.destroy : true
			end
	  end
	end
end
