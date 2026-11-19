class ProductsController < ApplicationController
  PER_PAGE = 9
  FILTERS = { "on_sale" => :on_sale, "new" => :recently_added, "updated" => :recently_updated }.freeze

  # Also handles keyword search (2.6): ?q=tent&category_id=3
  def index
    @products = Product.active.with_attached_image.includes(:categories)
    @products = @products.public_send(FILTERS[params[:filter]]) if FILTERS.key?(params[:filter])
    @products = @products.search(params[:q])
    @products = @products.in_category(params[:category_id]) if params[:category_id].present?
    @products = @products.order(:name).page(params[:page]).per(PER_PAGE)
    set_breadcrumbs(["Products", nil])
  end

  def show
    @product = Product.active.find(params[:id])
    @category = @product.categories.first
    @related = @product.related_products
    crumbs = []
    crumbs << [@category.name, category_path(@category)] if @category
    crumbs << [@product.name, nil]
    set_breadcrumbs(*crumbs)
  end
end
