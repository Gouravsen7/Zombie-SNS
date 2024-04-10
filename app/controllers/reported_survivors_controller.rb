class ReportedSurvivorsController < ApplicationController
  def create
    report = ReportedSurvivor.new(reported_survivors_params)
    return render json: { errors: report.errors.full_messages }, status: 422 unless report.save

    render json: { report:, message: 'Survivor Reported sucessfully' }, status: 201
  end

  private

  def reported_survivors_params
    params.require(:reported_survivor).permit(:reported_by, :reported_to)
  end
end
