class HomeController < ApplicationController
  def index
    scope = Product.active.with_attached_image
    @new_arrivals = scope.order(created_at: :desc).limit(8)
    @sale_products = scope.on_sale.limit(4)
  end
end
