# frozen_string_literal: true

class Survivor < ApplicationRecord
  has_many :items, dependent: :destroy
  has_many :reported_survivors_as_reported_by, class_name: 'ReportedSurvivor', foreign_key: 'reported_by',
                                               dependent: :destroy
  has_many :reported_survivors_as_reported_to, class_name: 'ReportedSurvivor', foreign_key: 'reported_to',
                                               dependent: :destroy
  accepts_nested_attributes_for :items

  enum gender: %i[female male other]
  validates :name, presence: true, uniqueness: true
  validates :age, presence: true, numericality: true
  validates :latitude, numericality: { format: { with: /-?\d{1,6}\.\d{1,3}/ } }
  validates :longitude, numericality: { format: { with: /-?\d{1,6}\.\d{1,3}/ } }
  scope :infected_count, -> { where(infected: true).count.to_f }
  scope :non_infected_count, -> { where(infected: false).count.to_f }

  def check_items
    items_hash = items.index_by(&:item)
    ['water', 'first aid'].each do |item_name|
      errors.add(:item, "#{item_name} must exist") unless items_hash.key?(item_name)
    end
  end

  def self.find_by_name(name)
  	find_by(name: name)
  end

  def self.survivor_percentage(survivor_count)
    total_survivors = count.to_f
    total_survivors.positive? ? (survivor_count / total_survivors.to_f * 100).round(2) : 0
  end

  def self.total_points_lost_per_item
    where(infected: true)
      .joins(:items)
      .group('items.item')
      .sum('items.points * items.quantity')
  end

  def self.average_item_amounts
    total_survivors = non_infected_count

    item_counts = where(infected: false)
                  .joins(:items)
                  .group('items.item')
                  .sum('items.quantity')
    item_counts.transform_values do |total_amount|
      (total_amount / total_survivors).round(2)
    end
  end

  def self.infected_survivors(trade_to, trade_by)
  	if trade_to&.infected && trade_by&.infected
  		"Trade not possible: both servivors infected"
  	else
    	check_infected_survivor(trade_to, "trade_to") || check_infected_survivor(trade_by, "trade_by")
    end
  end

  def self.is_trade_found(trade_to, trade_by, trade_by_name, trade_to_name)
    unless trade_to && trade_by
    	"Both Serrvivors not found"
		else
		  trade_found(trade_by, trade_by_name) || trade_found(trade_to, trade_to_name)
		end
	end

	def self.check_trade_items(sender_items, receiver_items, sender, receiver)

    sender_db_items = sender.items.where(item: receiver_items.map { |inventory| inventory[:item] }).index_by(&:item)
    receiver_db_items = receiver.items.where(item: sender_items.map { |inventory| inventory[:item] }).index_by(&:item)
		sender_points = match_quantity_of_items(sender_db_items, receiver_items)
		receiver_points = match_quantity_of_items(receiver_db_items, sender_items)
		{
			sender_points: sender_points,
			receiver_points: receiver_points
		}
  end

  private

  def self.trade_found(survivor, name)
  	"Survivor not found: #{name}" unless survivor
  end

  def self.check_infected_survivor(survivor, survivor_type)
    "Trade not possible: #{survivor_type} survivor #{survivor&.name} is infected" if survivor&.infected
  end

  def self.match_quantity_of_items(survivor_items, items)
    points = 0
    error_message = nil
 
    items.each do |inventory|
      item_points = survivor_items[inventory[:item]]
      unless item_points.present? && item_points.quantity > inventory[:quantity]
       	error_message = "For the survivor, item #{inventory[:item]} or its quantity #{inventory[:quantity]} does not match, trade cannot proceed"
      	break
      else
        points += item_points.points * inventory[:quantity]
      end
    end

    error_message ? { error: error_message } : { points: points, error: error_message}
  end
end
