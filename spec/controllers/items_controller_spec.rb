require 'rails_helper'

RSpec.describe ItemsController, type: :controller do
	describe 'GET#trade_items' do
		let!(:survivor1) {
      create(:survivor, items_attributes: [
      { item: 'water', quantity: 3 , points: 4},
      { item: 'first aid', quantity: 5 , points: 2},
      ])
    }
		let!(:survivor2) {
      create(:survivor, items_attributes: [
      { item: 'water', quantity: 3 , points: 4},
      { item: 'first aid', quantity: 5 , points: 2},
      ])
    }
		let!(:item1) {create(:item, item: 'AK47', survivor_id: survivor1.id, quantity: 3)}
		let!(:item2) {create(:item, item: 'soup', survivor_id: survivor2.id, quantity: 3)}

		context 'Trading process' do
			it 'When trade Successful' do 
				get :trade_items, params: {"trade_to": survivor1.id, "trade_by": survivor2.id, "trade_to_items": [ {"item_id": item2.id, "quantity": 1} ], "trade_by_items": [ {"item_id": item1.id, "quantity": 1} ] }
        expect(JSON.parse(response.body)["data"]["message"]).to eq("Trade Successfully")
			end

			it 'survivor not found' do 
				get :trade_items, params: {"trade_to": "sakshi 13",   "trade_by": "sakshi 14",   "trade_to_items": [ {"item_id": item2.id, "quantity": 1} ], "trade_by_items": [ {"item_id": item1.id, "quantity": 1} ] }
				expect(JSON.parse(response.body)['errors']).to eq('Either one of them is not present')
			end

			it 'when trade points not match' do 
				item1.update(points: 12)
				get :trade_items, params: {"trade_to": survivor1.id, "trade_by": survivor2.id, "trade_to_items": [ {"item_id": item2.id, "quantity": 1} ], "trade_by_items": [ {"item_id": item1.id, "quantity": 1} ] }
				expect(JSON.parse(response.body)["errors"]).to eq("Trade not possible: points does not match")
			end

		end
	end

end
