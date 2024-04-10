class ItemsController < ApplicationController
	before_action :check_infected_survivors, only: [:trade_items]
	before_action :get_survivors, only: [:trade_items]
	before_action :parse_trade_items, only: :trade_items
	# before_action :check_trade_items, only: :trade_items

	def trade_items
		# trade_by_items = parse_trade_items(params[:trade_by_items])
		# trade_to_items = parse_trade_items(params[:trade_to_items])

		return unless trade_to_points = check_trade_items(@trade_by_items, @trade_to)
		return unless trade_by_points = check_trade_items(@trade_to_items, @trade_by)
 
		return render json: {errors: "Trade not possible: points do not match"} unless @trade_to_points == @trade_by_points

		Item.update_quantity(@trade_to_items, @trade_to, @trade_by)
		Item.update_quantity(@trade_by_items, @trade_by, @trade_to)

		# Item.update_item(trade_to_items, @trade_by)
		# Item.update_item(trade_by_items, @trade_to)

		render json: {message: "Trade Successfully"}
	end

	private

	def get_survivors
		@trade_to = Survivor.get_survivor(params[:trade_to])
		@trade_by = Survivor.get_survivor(params[:trade_by])

		error_for = params[:trade_to] || params[:trade_by]
	  return render json: { errors: "Trade not possible: #{error_for} survivor not found" }, status: :not_found unless @trade_by && @trade_to
	end

	def check_infected_survivors
	  check_infected_survivor(@trade_to, "trade_to")
	  check_infected_survivor(@trade_by, "trade_by")
	end

	def check_infected_survivor(survivor, survivor_type)
	  render_error("Trade not possible: #{survivor_type} survivor is infected", :unprocessable_entity) if survivor&.infected
	end

	def parse_trade_items
	  @trade_by_items = params[:trade_by_items].map do |item|
	    { item: item['item'], quantity: item['quantity'].to_i }
	  end

	  @trade_to_items = params[:trade_to_items].map do |item|
	    { item: item['item'], quantity: item['quantity'].to_i }
	  end
	end

	def check_trade_items(items, survivor)
		points = 0
		items.each do |inventory|
			item_points = survivor.items.where("item = ? AND quantity >= ?", inventory[:item], inventory[:quantity])&.first
			if item_points.nil?
				render json: {errors: "for the survivor #{survivor.name} their item  #{inventory[:item]} or their quantity #{inventory[:quantity]} is not match so you can't trade"}
				return false
				break
			else
				points += (item_points.points * inventory[:quantity])
			end
		end
		return points if points > 0
	end

end
