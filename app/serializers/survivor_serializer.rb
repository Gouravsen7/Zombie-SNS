class SurvivorSerializer < ActiveModel::Serializer
  attributes :id, :user_name, :name, :age, :latitude, :longitude, :gender, :infected

  has_many :items
end