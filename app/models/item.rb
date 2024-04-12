class Item < ApplicationRecord
	attr_accessor :cache_selling_quantity
	belongs_to :survivor
  validate :check_quantity, on: :create
  after_initialize :set_points
  scope :essentials, -> { where("lower(item) IN (?) AND quantity <= ?", BASIC_ITEMS_NAME, 0) }

  def check_quantity
    errors.add(:quantity, "Quantity must be greater than 0") if !quantity.nil? &&  quantity <= 0
  end

  def set_points
    item.downcase!
    item_points = {
      "water" => 14,
      "first aid" => 10,
      "soup" => 12,
      "ak47" => 8
    }
    self.points = item_points[item]
  end
end
