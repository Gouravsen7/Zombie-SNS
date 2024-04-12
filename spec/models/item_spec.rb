require 'rails_helper'

RSpec.describe Item, type: :model do
  
  let(:survivor) { create(:survivor, items_attributes: [
      { item: 'water', quantity: 3 , points: 4},
      { item: 'first aid', quantity: 5 , points: 2},
    ]) 
  }

  let(:basic_item_name) { "water" }
  
  describe "scopes" do
    describe "essentials" do
      before do
        @non_essential_item = Item.find_by_item('water')
        @essential_item = Item.find_by_item('first aid')
      end
      
      it "excludes items with quantity > 0 or names not in BASIC_ITEMS_NAME" do
        expect(Item.essentials).not_to include(@non_essential_item)
      end
    end
  end
  
  describe "cache_selling_quantity" do
    let(:item) { Item.new(item: "ak47", quantity: 10, points: 12, survivor: survivor) }
    
    it "returns the cache_selling_quantity value" do
      item.cache_selling_quantity = 5
      expect(item.cache_selling_quantity).to eq(5)
    end
    
    it "can be set and retrieved" do
      item.cache_selling_quantity = 8
      expect(item.cache_selling_quantity).to eq(8)
    end
  end
end
