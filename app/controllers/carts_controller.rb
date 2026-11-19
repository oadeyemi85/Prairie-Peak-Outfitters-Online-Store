class CartsController < ApplicationController
  def show
    @lines = current_cart.lines
    set_breadcrumbs(["Cart", nil])
  end
end
