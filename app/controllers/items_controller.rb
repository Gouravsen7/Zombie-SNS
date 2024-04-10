class ItemsController < ApplicationController
  before_action :parse_trade_items, only: :trade_items
  before_action :get_survivors, only: :trade_items
  before_action :check_infected_survivors, only: :trade_items

  def trade_items
    begin
			points = Survivor.check_trade_items(@trade_by_items, @trade_to_items, @trade_by, @trade_to)
			if points[:receiver_points][:error] || points[:sender_points][:error]
				return render_error(error: points[:receiver_points][:error] || points[:sender_points][:error])
			end
	 		
			return render json: {errors: "Trade not possible: points does not match"} unless points[:sender_points] == points[:receiver_points]

			Item.send_item_detail(@trade_to_items, @trade_to, @trade_by, @trade_by_items)

			render json: {message: "Trade Successfully"}, status: 200
		rescue ActionController::BadRequest => e
      render json: ErrorSerializer.serialize(e.message), status: :unprocessable_entity
    end
	end

  private
  
  def parse_trade_items
    @trade_by_items = parse_items(params[:trade_by_items])
    @trade_to_items = parse_items(params[:trade_to_items])
  end

  def get_survivors
    @trade_to = Survivor.find_by_name(params[:trade_to])
    @trade_by = Survivor.find_by_name(params[:trade_by])
		
		error_messages = Survivor.is_trade_found(@trade_to, @trade_by, params[:trade_by], params[:trade_to])
		render_error(error_messages) if error_messages
  end

  def check_infected_survivors
    error_message = Survivor.infected_survivors(@trade_to, @trade_by)
    render_error(error_message) if error_message
  end
end
