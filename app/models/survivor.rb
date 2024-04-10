# frozen_string_literal: true

class Survivor < ApplicationRecord
  has_many :items, dependent: :destroy
  has_many :reported_survivors_as_reported_by, class_name: 'ReportedSurvivor', foreign_key: 'reported_by',
                                               dependent: :destroy
  has_many :reported_survivors_as_reported_to, class_name: 'ReportedSurvivor', foreign_key: 'reported_to',
                                               dependent: :destroy
  accepts_nested_attributes_for :items

  enum gender: %i[female male other]
  validates :name, :age, presence: true
  validates :user_name, presence: true, uniqueness: true
  validates :latitude, numericality: { format: { with: /-?\d{1,6}\.\d{1,3}/ } }
  validates :longitude, numericality: { format: { with: /-?\d{1,6}\.\d{1,3}/ } }
  validate :check_items

  scope :non_infected, -> { where(infected: false) }
  scope :infected, -> { where(infected: true) }
  scope :infected_count, -> { infected.count.to_f }
  scope :non_infected_count, -> { non_infected.count.to_f }
 
  def check_items
    items_hash = items.index_by(&:item)
    ['water', 'first aid'].each do |item_name|
      errors.add(:item, "#{item_name} must exist") unless items_hash.key?(item_name)
    end
  end

  def self.survivor_percentage(survivor_count)
    total_survivors = count.to_f
    total_survivors.positive? ? (survivor_count / total_survivors.to_f * 100).round(2) : 0
  end

  def self.total_points_lost_per_item
    infected
      .joins(:items)
      .group('items.item')
      .sum('items.points * items.quantity')
  end

  def self.average_item_amounts
    total_survivors = non_infected_count

    item_counts = non_infected
                  .joins(:items)
                  .group('items.item')
                  .sum('items.quantity')
    item_counts.transform_values do |total_amount|
      (total_amount / total_survivors).round(2)
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

  def self.match_quantity_of_items(survivor_items, items)
    points = 0
    error_message = nil
 
    items.each do |inventory|
      item_points = survivor_items[inventory[:item]]
      unless item_points.present? && item_points.quantity >= inventory[:quantity]
       	error_message = "For the survivor, item #{inventory[:item]} or its quantity #{inventory[:quantity]} does not match, trade cannot proceed"
      	break
      else
        points += item_points.points * inventory[:quantity]
      end
    end
    error_message ? { error: error_message } : { points: points, error: error_message}
  end
end
