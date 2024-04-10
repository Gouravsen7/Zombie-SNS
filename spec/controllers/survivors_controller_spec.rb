require 'rails_helper'

RSpec.describe SurvivorsController, type: :controller do
  describe 'POST #create' do
    context 'with valid parameters' do
      let(:valid_params) { { survivor: attributes_for(:survivor) } }

      it 'creates a new survivor' do
        expect do
          post :create, params: valid_params
        end.to change(Survivor, :count).by(1)
      end

      it 'returns a success response' do
        post :create, params: valid_params
        expect(response).to have_http_status(:created)
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
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error messages' do
        post :create, params: invalid_params
        expect(JSON.parse(response.body)['errors']).to be_present
      end
    end
  end

  describe 'PATCH #update' do
    let(:survivor) { create(:survivor) }

    context 'when survivor is infected' do
      before { survivor.update(infected: true) }

      it 'returns an unprocessable entity response' do
        patch :update, params: { id: survivor.id, survivor: { name: 'Updated Name' } }
        expect(response).to have_http_status(422)
        expect(JSON.parse(response.body)['errors']).to eq('infected user')
      end
    end

    context 'when survivor is not infected' do
      it 'updates the survivor' do
        patch :update, params: { id: survivor.id, survivor: { name: 'Updated Name' } }
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['data']['name']).to eq('Updated Name')
      end

      it 'returns a success response' do
        patch :update, params: { id: survivor.id, survivor: { name: 'Updated Name' } }
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when survivor is not found' do
      it 'returns a not found response' do
        patch :update, params: { id: 'invalid_id', survivor: { name: 'Updated Name' } }
        expect(response).to have_http_status(:not_found)
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
        expect(JSON.parse(response.body)['messages']).to eq('Report Generated')
      end
    end
  end
end
