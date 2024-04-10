class SurvivorsController < ApplicationController
	before_action :find_survivor, only: :update

	def index 
		servivors = Survivor.all
		render json: { message: "Servivors not found"}, status: 404  unless servivors
       
		render json: servivors, status: 201
	end

	def create
		survivor = Survivor.new(survivor_params)
		if survivor.save
			render json: {data: survivor, message: "successfully created"}, status: 201
		else
      render json: {errors: survivor.errors.full_messages}, status: 422  
    end
	end

	def update
		return render json: {errors: "infected user"}, status: 422 unless @survivor.infected

		if @survivor.update(survivor_params)
			render json: {data: @survivor, message: "successfully updated"}, status: 200
		else
			render json: {errors: @survivor.errors.full_messages}, status: 422
		end
	end

	private

	def find_survivor
		@survivor = Survivor.find_by_id(params[:id])
		return render json: {errors: "survivor not found"}, status: :not_found unless @survivor
	end

	def survivor_params
		params.require(:survivor).permit(:name, :age, :gender, :latitude, :longitude, items_attributes: [:item, :points, :quantity])
	end
end
