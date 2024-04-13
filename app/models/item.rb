class Item < ApplicationRecord
	attr_accessor :cache_selling_quantity
	belongs_to :survivor
  # validates :description, presence: true, if: -> { first_step? || require_validation }

  validates_numericality_of :quantity, greater_than_or_equal_to: 1, if: -> {BASIC_ITEMS_NAME.include?(item)}
  # before_save :check_quantity#, on: :create
  # after_initialize :normalize_item
  scope :essentials, -> { where("lower(item) IN (?) AND quantity <= ?", BASIC_ITEMS_NAME, 0) }
end
