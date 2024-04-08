class SurvivorsController < ApplicationController
	before_action :find_survivor, only: [:update, :destroy]
	def index
		survivor = Survivor.all
	end

	def create
		survivor = Survivor.new(survivor_params)
		if survivor.save
			render json: survivor, status: 200
		else
      render json: {errors: survivor.errors.full_messages}, status: 422  
    end
	end

	def update
		if @survivor.infected == "true"
			render json: {errors: "not accesible"}, status: 422
		else
			@survivor.update(survivor_params)
		end
	end

	def destroy
	end

	private

	def find_survivor
		@survivor = Survivor.find_by_id(params[:id])
		render json: {errors: "survivor not found"}, status: :not_found unless @survivor
	end

	def survivor_params
		params.permit(:name, :age, :gender, :lattitude, :longitude)
	end
end
