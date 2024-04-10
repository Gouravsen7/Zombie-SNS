class ApplicationController < ActionController::API
	def parse_items(items_params)
    items_params.map { |item| { item: item['item'], quantity: item['quantity'].to_i } }
  end
  
  def render_error(error_message)
    render json: { errors: error_message }, status: :unprocessable_entity
  end
end
