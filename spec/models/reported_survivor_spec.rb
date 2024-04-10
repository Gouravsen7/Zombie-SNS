# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReportedSurvivor, type: :model do
  let(:reported_by_survivor) { create(:survivor) }
  let(:reported_to_survivor) { create(:survivor) }

  describe 'validations' do
    it {
      should validate_uniqueness_of(:reported_to).scoped_to(:reported_by).with_message('is already reported by this Survivor')
    }
  end

  describe 'custom validations' do
    context 'when reporter and reported survivor are the same' do
      it 'adds an error' do
        reported_survivor = build(:reported_survivor, reported_by: reported_by_survivor.id,
                                                      reported_to: reported_by_survivor.id)
        reported_survivor.valid?
        expect(reported_survivor.errors[:base]).to include('Reporter and Reported Survivor cannot be the same')
      end
    end

    context 'when reported_by survivor is infected' do
      it 'adds an error' do
        reported_by_survivor.update(infected: true)
        reported_survivor = build(:reported_survivor, reported_by: reported_by_survivor.id,
                                                      reported_to: reported_to_survivor.id)
        reported_survivor.valid?
        expect(reported_survivor.errors[:reported_by]).to include('is infected Survivor and cannot report others')
      end
    end

    context 'when reported_to survivor is infected' do
      it 'adds an error' do
        reported_to_survivor.update(infected: true)
        reported_survivor = build(:reported_survivor, reported_by: reported_by_survivor.id,
                                                      reported_to: reported_to_survivor.id)
        reported_survivor.valid?
        expect(reported_survivor.errors[:reported_to]).to include('is already infected')
      end
    end
  end
end
