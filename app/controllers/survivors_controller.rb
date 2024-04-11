class SurvivorsController < ApplicationController
  include ResourceRenderer
  before_action :find_survivor, only: :update

  def index
    servivors = Survivor.non_infected
    render_success_response({
                              Survivor: array_serializer.new(servivors, message: 'Survivors found successfully',
                                                                        serializer: SurvivorSerializer, action: :index)
                            })
  end

  def create
    survivor = Survivor.new(survivor_params)
    if survivor.save
      render_success_response({
                                Survivor: single_serializer(survivor, SurvivorSerializer)
                              }, 'Survivor created sucessfully')
    else
      render_unprocessable_entity_response(survivor, 'Validation failed')
    end
  end

  def update
    if @survivor.update(survivor_params)
      render_success_response({
                                Survivor: single_serializer(@survivor, SurvivorSerializer)
                              }, 'Survivor successfully updated')
    else
      render_unprocessable_entity_response(@survivor, 'Validation failed')
    end
  end

  def report
    data = { messages: 'Report Generated',
             infected_survivours: Survivor.survivor_percentage(Survivor.infected_count).to_s + '%',
             non_infected_survivors: Survivor.survivor_percentage(Survivor.non_infected_count).to_s + '%',
             resource_average_amount_per_survivor: Survivor.average_item_amounts,
             infected_survivor_lost_point: Survivor.total_points_lost_per_item }
    render_success_response(resources: data, message: 'Report generated successfully')
  end

  private

  def find_survivor
    @survivor = Survivor.find_by(id: params[:id])
    render json: { errors: 'survivor not found' }, status: :not_found unless @survivor
  end

  def survivor_params
    params.require(:survivor).permit(:user_name, :name, :age, :gender, :latitude, :longitude,
                                     items_attributes: %i[item points quantity])
  end
end
