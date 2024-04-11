require 'rails_helper'

RSpec.describe SurvivorsController, type: :controller do
  describe 'GET#index' do 
    let(:survivor) { create(:survivor, items_attributes: [
        { item: 'water', quantity: 3 , points: 4},
        { item: 'first aid', quantity: 5 , points: 2},
      ]) 
    }

    context 'for all non infected survivor' do
      it 'should display all non infected survivor' do
        get :index
        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      let(:valid_params) { { survivor: attributes_for(:survivor, items_attributes: [{ item: 'water', quantity: 3 , points: 4},{ item: 'first aid', quantity: 5 , points: 2}])} }

      it 'creates a new survivor' do
        expect do
          post :create, params: valid_params
        end.to change(Survivor, :count).by(1)
      end

      it 'returns a success response' do
        post :create, params: valid_params
        expect(response).to have_http_status(200)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) { { survivor: attributes_for(:survivor, name: nil) } }

      it 'does not create a new survivor' do
        expect do
          post :create, params: invalid_params
        end.to_not change(Survivor, :count)
      end

      it 'returns an unprocessable entity response' do
        post :create, params: invalid_params
        expect(JSON.parse(response.body)["status"]).to eq(422)
      end

      it 'returns error messages' do
        post :create, params: invalid_params
        expect(JSON.parse(response.body)['errors']).to be_present
      end
    end
  end

  describe 'PATCH #update' do
    let(:survivor) { create(:survivor, items_attributes: [
      { item: 'water', quantity: 3 , points: 4},
      { item: 'first aid', quantity: 5 , points: 2},
      ]) }

    context 'when survivor is infected' do
      before { survivor.update(infected: true) }

      it 'returns an unprocessable entity response' do
        patch :update, params: { id: survivor.id, survivor: { name: 'Updated Name' } }
        expect(JSON.parse(response.body)["status"]).to eq(422)
        expect(JSON.parse(response.body)['errors']).to eq("survivor is infected, So you can not update!")
      end
    end

    context 'when survivor is not infected' do
      it 'updates the survivor' do
        patch :update, params: { id: survivor.id, survivor: { name: 'Updated Name' } }
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)["data"]["Survivor"]["name"]).to eq('Updated Name')
      end

      it 'returns a success response' do
        patch :update, params: { id: survivor.id, survivor: { name: 'Updated Name' } }
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when survivor is not found' do
      it 'returns a not found response' do
        patch :update, params: { id: 'invalid_id', survivor: { name: 'Updated Name' } }
        expect(JSON.parse(response.body)["status"]).to eq(404)
      end

      it 'returns error message' do
        patch :update, params: { id: 'invalid_id', survivor: { name: 'Updated Name' } }
        expect(JSON.parse(response.body)['errors']).to eq('survivor not found')
      end
    end
  end

  describe 'Get#report' do
    let(:survivor) { create(:survivor) }
    let(:infected_survivor) { create(:survivor, infected: true) }
    let(:item) { create(:item, survivor_id: survivor.id) }
    context 'survivor report' do
      it 'retrun report' do
        get :report
        expect(JSON.parse(response.body)["data"]["resources"]["messages"]).to eq('Report Generated')
      end
    end
  end
end
