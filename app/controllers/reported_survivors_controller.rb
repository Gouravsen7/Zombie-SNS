class ReportedSurvivorsController < ApplicationController
  def create
    report = ReportedSurvivor.new(reported_survivors_params)
    if report.save
      render_success_response(report, 'Survivor Reported sucessfully')
    else
      render_unprocessable_entity_response(report, 'Validation failed')
    end
  end

  private

  def reported_survivors_params
    params.require(:reported_survivor).permit(:reported_by, :reported_to)
  end
end
