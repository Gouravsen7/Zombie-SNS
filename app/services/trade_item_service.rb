class TradeItemService < ApplicationService
  attr_reader :sender, :receiver, :sender_items, :receiver_items

  def initialize(sender, receiver, item_params)
    @sender = sender
    @receiver = receiver
    @sender_items = item_params[:trade_by_items]
    @receiver_items = item_params[:trade_to_items]
  end

  def call
    check_dead
    success? && match_traders_points
  end

  private

  def check_dead
    (sender.dead? || receiver.dead?) && errors.add(:message, 'Trade not possible traders are dead') 
  end

  def match_traders_points
    sender_points = calculate_point(@sender, @receiver_items)
    receiver_points = calculate_point(@receiver, @sender_items)

    return errors.add(:points, 'Trade not possible: points does not match') unless sender_points&.eql?(receiver_points)

    trading
  end

  def calculate_point(survior, query_items)
    survior_items = survior.items.where(raw_query_by_items(query_items))
    return 0 unless survior_items.count == query_items.count
    points = 0
    survior_items = query_items.map do |qt|
      item = survior_items.find(qt[:item_id])
      points += item.points * qt[:quantity].to_i
      item.cache_selling_quantity = qt[:quantity].to_i
      item
    end
    survior.cache_trading_items = survior_items
    points
  end

  def trading
   result = ActiveRecord::Base.transaction do
      sender.cache_trading_items.each do |item|
        sender.trade_item(item, receiver)
      end

      receiver.cache_trading_items.each do |item|
        receiver.trade_item(item, sender)
      end
    end
    debugger
  end

  def raw_query_by_items(query_items)
  	query_items.map { |item| "(id = #{item[:item_id]} AND quantity >= #{item[:quantity]})" }.join(" OR ")
  end
end