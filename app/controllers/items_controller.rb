# frozen_string_literal: true

class ItemsController < ApplicationController
  before_action :survivors_present, only: :trade_items
  before_action :check_infected_survivors, only: :trade_items

  def trade_items
  	trade_result = TradeItems.new(@trade_by, @trade_to, params).match_item_points
  	unless trade_result[:error_message].nil?
    	render_unprocessable_entity(trade_result[:error_message])
    else
    	render_success_response(
      	resources: { trade_to: single_serializer(@trade_to, SurvivorSerializer),
        	           trade_by: single_serializer(@trade_to,
          	                                     SurvivorSerializer) }, message: 'Trade Successfully'
    	)
    end
  end

  private


  def survivors_present
    @trade_to = Survivor.find_by_id(params[:trade_to])
    @trade_by = Survivor.find_by_id(params[:trade_by])
    render_unprocessable_entity('Either one of them is not present') unless @trade_to && @trade_to
  end

  def check_infected_survivors
    return unless @trade_to.infected && @trade_by.infected

    render_unprocessable_entity('Either one of them is infected')
  end
end
