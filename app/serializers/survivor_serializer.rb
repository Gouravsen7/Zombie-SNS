class SurvivorSerializer < ActiveModel::Serializer
  attributes :id, :name, :age, :latitude, :longitude, :gender, :infected

  has_many :items
end