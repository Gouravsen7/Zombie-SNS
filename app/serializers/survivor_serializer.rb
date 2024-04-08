class SurvivorSerializer < ActiveModel::Serializer
  attributes :id, :name, :age, :latitude, :longitude, :gender

  has_many :items
end