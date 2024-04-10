# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Item, type: :model do
  describe '#is_item_valid?' do
    let(:survivor) { 
      create(:survivor, items_attributes: [
      { item: 'water', quantity: 3 , points: 4},
      { item: 'first aid', quantity: 5 , points: 2},
      ])
    }

    it 'returns true if the item includes the specified string' do
      item = create(:item, survivor:)
      expect(item.is_item_valid?('water')).to eq(true)
    end

    it 'returns false if the item does not include the specified string' do
      item = create(:item, item: 'food', survivor:)
      expect(item.is_item_valid?('water')).to eq(false)
    end
  end
end
