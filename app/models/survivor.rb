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

  scope :get_survivor, ->(name) { find_by(name:) }
  scope :infected_count, -> { where(infected: true).count.to_f }
  scope :non_infected_count, -> { where(infected: false).count.to_f }

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
    where(infected: true)
      .joins(:items)
      .group('items.item')
      .sum('items.points * items.quantity')
  end

  def self.average_item_amounts
    total_survivors = where(infected: false).count.to_f

    item_counts = where(infected: false)
                  .joins(:items)
                  .group('items.item')
                  .sum('items.quantity')

    item_counts.transform_values do |total_amount|
      (total_amount / total_survivors).round(2)
    end
  end
end
