class ItemsController < ApplicationController
  before_action :parse_trade_items, only: :trade_items
  before_action :get_survivors, only: [:trade_items]
  before_action :check_infected_survivors, only: [:trade_items]

  def trade_items
    begin
      return unless trade_to_points = check_trade_items(@trade_by_items, @trade_to)
      return unless trade_by_points = check_trade_items(@trade_to_items, @trade_by)
      return render_error("Trade not possible: points do not match") unless trade_to_points == trade_by_points

      Item.update_quantity(@trade_to_items, @trade_to, @trade_by)
      Item.update_quantity(@trade_by_items, @trade_by, @trade_to)

      render json: { message: "Trade Successfully" }
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
		
		Survivor.is_trade_found(trade_to, trade_by, trade_by_name, trade_to_name)
  end

  def check_infected_survivors
    error_message = Survivor.infected_survivors(@trade_to, @trade_by)
    render_error(error_message) if error_message
  end

  def check_trade_items(items, survivor)
    points = 0
    items.each do |inventory|
      item_points = survivor.items.where(item: inventory[:item]).first
      if item_points.nil? || item_points.quantity < inventory[:quantity]
        render_error("Trade not possible: for the survivor #{survivor.name}, item '#{inventory[:item]}' or quantity #{inventory[:quantity]} is not enough for trading")
      else
        points += (item_points.points * inventory[:quantity])
      end
    end
    points
  end
end
