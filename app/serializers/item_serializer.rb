class ItemSerializer < ActiveModel::Serializer
  attributes :id, :item, :points, :quantity
end