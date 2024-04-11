# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Survivor, type: :model do
  describe 'associations' do
    it { should have_many(:items).dependent(:destroy) }
    it {
      should have_many(:reported_survivors_as_reported_by)
        .class_name('ReportedSurvivor')
        .with_foreign_key('reported_by')
        .dependent(:destroy)
    }
    it {
      should have_many(:reported_survivors_as_reported_to)
        .class_name('ReportedSurvivor')
        .with_foreign_key('reported_to')
        .dependent(:destroy)
    }
  end

  describe 'nested attributes' do
    it { should accept_nested_attributes_for(:items) }
  end

  describe 'validations' do
    it { should validate_presence_of(:age) }
    it { should validate_presence_of(:name) }
    it { should validate_numericality_of(:latitude) }
    it { should validate_numericality_of(:longitude) }
  end

  describe 'enums' do
    it { should define_enum_for(:gender).with_values(%i[female male other]) }
  end
end
