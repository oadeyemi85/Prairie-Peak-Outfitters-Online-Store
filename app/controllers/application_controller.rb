class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  helper_method :current_cart, :nav_categories

  private

  def current_cart
    @current_cart ||= Cart.new(session)
  end

  def nav_categories
    @nav_categories ||= Category.order(:name)
  end

  def configure_permitted_parameters
    account_attributes = %i[email username first_name last_name phone address_line1 address_line2 city postal_code province_id]
    devise_parameter_sanitizer.permit(:sign_up, keys: account_attributes)
    devise_parameter_sanitizer.permit(:account_update, keys: account_attributes)
  end

  def set_breadcrumbs(*crumbs)
    @breadcrumbs = [["Home", root_path]] + crumbs
  end
end
