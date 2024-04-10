class SurvivorsController < ApplicationController
  before_action :find_survivor, only: :update

	def index 
		servivors = Survivor.non_infected
		render json: { message: "Servivors not found"}, status: 404  unless servivors
       
		render json: servivors, status: 200
	end

  def create
    survivor = Survivor.new(survivor_params)
    if survivor.save
      render json: { data: SurvivorSerializer.new(survivor), message: 'successfully created' }, status: 201
    else
      render json: { errors: survivor.errors.full_messages }, status: 422
    end
  end

  def update
    return render json: { errors: 'infected user' }, status: 422 if @survivor.infected

    if @survivor.update(survivor_params)
      render json: { data: SurvivorSerializer.new(@survivor), message: 'successfully updated' }, status: 200
    else
      render json: { errors: @survivor.errors.full_messages }, status: 422
    end
  end

  def report
    render json: {	messages: 'Report Generated',
                   	infected_survivours: Survivor.survivor_percentage(Survivor.infected_count).to_s+"%" ,
                   	non_infected_survivors: Survivor.survivor_percentage(Survivor.non_infected_count).to_s+"%",
                   	resource_average_amount_per_survivor: Survivor.average_item_amounts,
                   	infected_survivor_lost_point: Survivor.total_points_lost_per_item 
                  }, status: 200
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
