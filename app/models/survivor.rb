class Survivor < ApplicationRecord
	has_many :items
	accepts_nested_attributes_for :items

	enum gender: [:female, :male, :other]
	validates :name, uniqueness: true
	validates :age, presence: true, numericality: true
	validates :latitude , numericality: { format: { with: /-?\d{1,6}\.\d{1,3}/}}
	validates :longitude, numericality: { format: { with: /-?\d{1,6}\.\d{1,3}/}}
	validate :check_items

	scope :get_survivor, ->(name){ find_by(name: name) }

	def check_items
	  items_hash = items.index_by(&:item)
	  ['water', 'first aid'].each do |item_name|
	    unless items_hash.key?(item_name)
	      errors.add(:item, "#{item_name} must exist")
	    end
	  end
	end

end
