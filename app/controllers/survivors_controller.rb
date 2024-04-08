class SurvivorsController < ApplicationController
	before_action :find_survivor, only: [:update, :destroy]
	def index
		survivor = Survivor.all
		render json: survivor
	end

	def create
		survivor = Survivor.new(survivor_params)
		if survivor.save
			render json: survivor, status: 201
		else
      render json: {errors: survivor.errors.full_messages}, status: 422  
    end
	end

	def update
		unless @survivor.infected != "false"
			return render json: {errors: "not accesible"}, status: 422
		end

		@survivor.update(survivor_params)
		if @survivor
			render json: {data: @survivor, message: "successfully updated"}, status: 200
		else
			render json: {errors: @survivor.errors.full_messages}, status: 422
		end
	end

	def destroy
	end

	private

	def find_survivor
		@survivor = Survivor.find_by_id(params[:id])
		return render json: {errors: "survivor not found"}, status: :not_found unless @survivor
	end

	def survivor_params
		params.require(:survivor).permit(:name, :age, :gender, :latitude, :longitude)
	end
end
