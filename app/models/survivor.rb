# frozen_string_literal: true

class Survivor < ApplicationRecord
	attr_accessor :cache_trading_items

  has_many :items, dependent: :destroy
  has_many :reported_survivors_as_reported_by, class_name: 'ReportedSurvivor', foreign_key: 'reported_by',
                                               dependent: :destroy
  has_many :reported_survivors_as_reported_to, class_name: 'ReportedSurvivor', foreign_key: 'reported_to',
                                               dependent: :destroy
  accepts_nested_attributes_for :items

  enum gender: %i[female male other]
  validates :name, :age, presence: true
  validates :latitude, numericality: { format: { with: /-?\d{1,6}\.\d{1,3}/ } }
  validates :longitude, numericality: { format: { with: /-?\d{1,6}\.\d{1,3}/ } }
  validate :check_items, on: :create

  scope :non_infected, -> { where(infected: false) }
  scope :infected, -> { where(infected: true) }
  scope :infected_count, -> { infected.count.to_f }
  scope :non_infected_count, -> { non_infected.count.to_f }

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

  def dead?
  	items.essentials.any?
  end

  
  def trade_item(item, survior)
    survior.items.find_or_create_by(item: item.item).update(quantity: item.quantity + item.cache_selling_quantity)
    items.find_by(item: item.item).update(quantity: item.quantity - item.cache_selling_quantity)
    debugger
    errors.any? ? errors : true
  end

  private

  def check_items
    items_hash = items.index_by { |item| item.item.downcase }
    BASIC_ITEMS_NAME.each do |item_name|
      errors.add(:item, "#{item_name} must exist") unless items_hash.key?(item_name)
    end
  end
end
