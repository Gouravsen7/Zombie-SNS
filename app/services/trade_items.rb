class TradeItems < ApplicationService

	def initialize(sender, receiver, item_data)
		@sender = sender
		@receiver = receiver
		@sender_items = item_data[:trade_by_items]		
		@receiver_items = item_data[:trade_to_items]		
	end

	def match_item_points
	  sender_points = calculate_point(@sender.items, @receiver_items)
	  receiver_points = calculate_point(@receiver.items, @sender_items)
	  unless sender_points > 0 && sender_points == receiver_points
	    return errors.add(error_message: 'Trade not possible: points does not match')
	  end
	  send_item_detail
	end
	

	def calculate_point(survior_items, items)
	  points = 0
	  
	  items.each do |inventory|
	    item = survior_items.find_by("id = ? AND quantity >= ?", inventory[:item_id], inventory[:quantity])
	    return points unless item
	    points += item.points * inventory[:quantity].to_i
	  end
	  points 
	end

	def send_item_detail
	  update_item(@receiver_items, @receiver, @sender)
	  update_item(@sender_items, @sender, @receiver)
	end

	def update_item(items, survivor1, survivor2)
		begin
			ActiveRecord::Base.transaction do 
				items.each do |item_params|
					resource = Item.find_by(id: item_params[:item_id])
			    item = survivor1.items.find_or_initialize_by(item: resource&.item)
			   	item.quantity = item.quantity? ? item.quantity + item_params[:quantity].to_i : item_params[:quantity].to_i
			    item.points ||= resource&.points
			    item.save

			    res = survivor2.items.find_by(id: item_params[:item_id])
					res.quantity -= item_params[:quantity].to_i
					res.quantity <= 0 ? res.destroy : res.save
					item = res.item.downcase
					if item == "water" || item == "first aid"
					  res.quantity <= 0 ? survivor2.destroy : true
					end
			  end
			  {success: true}
			end
		rescue => e
			errors.add(error_message: e.message)
		end
	end
end