class CartItemsController < ApplicationController
  def create
    product = Product.active.find(params[:product_id])
    if product.in_stock?
      current_cart.add(product, params.fetch(:quantity, 1))
      flash[:cart_notice] = "#{product.name} was added to your cart."
    else
      flash[:alert] = "Sorry, #{product.name} is out of stock."
    end
    redirect_back_or_to(cart_path)
  end

  # Quantity editing only; removal is a separate action.
  def update
    product = Product.active.find(params[:id])
    quantity = params[:quantity].to_i
    if quantity.positive?
      current_cart.set(product, quantity)
      flash[:notice] = "Quantity updated for #{product.name}."
    else
      flash[:alert] = "Quantity must be at least 1. Use Remove to delete an item."
    end
    redirect_to cart_path
  end

  def destroy
    current_cart.remove(params[:id])
    flash[:notice] = "Item removed from your cart."
    redirect_to cart_path
  end
end
