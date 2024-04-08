class Survivor < ApplicationRecord
	has_many :items

	enum gender: [:female, :male, :other]

	validates :name, presence: true
	validates :age, presence: true, numericality: true
	validates :latitude , numericality: { greater_than_or_equal_to:  -90, less_than_or_equal_to:  90 }
	validates :longitude, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }
end
