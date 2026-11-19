class OrdersController < ApplicationController
  before_action :authenticate_user!

  def index
    @orders = current_user.orders.includes(order_items: :product).order(created_at: :desc)
    set_breadcrumbs(["My orders", nil])
  end

  def show
    @order = current_user.orders.includes(order_items: :product).find(params[:id])
    set_breadcrumbs(["My orders", orders_path], ["Order ##{@order.id}", nil])
  end
end
