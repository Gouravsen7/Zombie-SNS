class ApplicationController < ActionController::API
  def parse_items(items_params)
    items_params.map { |item| { item: item['item'], quantity: item['quantity'].to_i } }
  end
end
