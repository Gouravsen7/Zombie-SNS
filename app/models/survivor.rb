class Survivor < ApplicationRecord
	has_many :items
	accepts_nested_attributes_for :items

	enum gender: [:female, :male, :other]
	validates :name, uniqueness: true
	validates :age, presence: true, numericality: true
	validates :latitude , numericality: { format: { with: /-?\d{1,6}\.\d{1,3}/}}
	validates :longitude, numericality: { format: { with: /-?\d{1,6}\.\d{1,3}/}}
	validate :check_items

	def check_items
	  items.each do |inventory|
	    water_exist = inventory.is_item_valid?('water')
	    aid_exist = inventory.is_item_valid?('first aid')
	    unless water_exist && aid_exist
	  		errors.add(:item, 'water and first aid must exist') 
	    end
	  end
	end
end
