class Item < ApplicationRecord
	attr_accessor :cache_selling_quantity
	belongs_to :survivor
  scope :essentials, -> { where("lower(item) IN (?) AND quantity <= ?", BASIC_ITEMS_NAME, 0) }
  validate :check_remaining_quantity, on: :update

  def check_remaining_quantity
	  errors.add(:quantity, "Trader can not perform trading because essntial item not sufficient") if BASIC_ITEMS_NAME.include?(item.downcase) && quantity.zero?
  	false
  end 
end
