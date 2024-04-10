require 'rails_helper'

RSpec.describe ReportedSurvivorsController, type: :controller do
  describe 'POST #create' do
    let(:reported_by) do
      create(:survivor, items_attributes: [
               { item: 'Water', quantity: 3, points: 4 },
               { item: 'first Aid', quantity: 5, points: 2 }
             ])
    end
    let(:reported_to) do
      create(:survivor, items_attributes: [
               { item: 'water', quantity: 3, points: 4 },
               { item: 'first aid', quantity: 5, points: 2 }
             ])
    end
    context 'with valid parameters' do
      let(:valid_params) { { reported_survivor: { reported_by: reported_by.id, reported_to: reported_to.id } } }

      it 'creates a new reported survivor' do
        expect do
          post :create, params: valid_params
        end.to change(ReportedSurvivor, :count).by(1)
      end

      it 'returns a success response' do
        post :create, params: valid_params
        expect(response).to have_http_status(:created)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) { { reported_survivor: { reported_to: reported_to.id } } }

      it 'does not create a new reported survivor' do
        expect do
          post :create, params: invalid_params
        end.to_not change(ReportedSurvivor, :count)
      end

      it 'returns an error response' do
        post :create, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
