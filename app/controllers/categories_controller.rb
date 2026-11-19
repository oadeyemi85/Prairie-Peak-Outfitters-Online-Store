class CategoriesController < ApplicationController
  def show
    @category = Category.find_by!(slug: params[:id])
    @products = @category.products.active.with_attached_image.order(:name).page(params[:page]).per(ProductsController::PER_PAGE)
    set_breadcrumbs([@category.name, nil])
  end
end
