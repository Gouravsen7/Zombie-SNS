class ItemsController < ApplicationController
  before_action :get_survivors, only: :trade_items
  before_action :check_infected_survivors, only: :trade_items
  before_action :parse_trade_items, only: :trade_items

  def trade_items
    points = Survivor.check_trade_items(@trade_by_items, @trade_to_items, @trade_by, @trade_to)
    if points[:receiver_points][:error] || points[:sender_points][:error]
      return render_error(error: points[:receiver_points][:error] || points[:sender_points][:error])
    end

    unless points[:sender_points] == points[:receiver_points]
      return render json: { errors: 'Trade not possible: points does not match' }
    end

    Item.send_item_detail(@trade_to_items, @trade_to, @trade_by, @trade_by_items)

    render json: { message: 'Trade Successfully' }, status: 200
  rescue ActionController::BadRequest => e
    render json: ErrorSerializer.serialize(e.message), status: :unprocessable_entity
  end

  private

  def parse_trade_items
    @trade_by_items = parse_items(params[:trade_by_items])
    @trade_to_items = parse_items(params[:trade_to_items])
  end

  def get_survivors
    @trade_to = Survivor.find_by_user_name(params[:trade_to])
    @trade_by = Survivor.find_by_user_name(params[:trade_by])
    render_error('Either one of them is not present') unless @trade_to && @trade_by
  end

  def check_infected_survivors
    render_error('Either one of them is infected') if @trade_to.infected && @trade_by.infected
  end
end
