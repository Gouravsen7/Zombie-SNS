class ReportedSurvivor < ApplicationRecord
  belongs_to :reported_by_survivor, class_name: 'Survivor', foreign_key: 'reported_by'
  belongs_to :reported_to_survivor, class_name: 'Survivor', foreign_key: 'reported_to'

  validate :different_reporter_and_reported_survivor
  validate :reported_by_not_infected
  validate :reported_to_is_infected
  validates :reported_to, uniqueness: { scope: :reported_by, message: 'is already reported by this Survivor' }
  after_save :is_reported_survivor_infected

  private

  def is_reported_survivor_infected
    reported_to_survivor.update(infected: true) if ReportedSurvivor.where(reported_to: reported_to).count >= 5
  end

  def different_reporter_and_reported_survivor
    errors.add(:base, 'Reporter and Reported Survivor cannot be the same') if reported_by == reported_to
  end

  def reported_by_not_infected
    errors.add(:reported_by, 'is infected Survivor and cannot report others') if reported_by_survivor&.infected
  end

  def reported_to_is_infected
    errors.add(:reported_to, 'is already infected') if reported_to_survivor&.infected
  end
end
