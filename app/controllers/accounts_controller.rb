class AccountsController < ApplicationController
  before_action :authenticate_user!

  def edit
    @user = current_user
    set_breadcrumbs(["My address", nil])
  end

  def update
    @user = current_user
    @user.assign_attributes(account_params)
    if @user.save(context: :checkout)
      destination = session.delete(:return_to_checkout) ? new_checkout_path : edit_account_path
      redirect_to destination, notice: "Your address details were saved."
    else
      set_breadcrumbs(["My address", nil])
      render :edit, status: :unprocessable_content
    end
  end

  private

  def account_params
    params.require(:user).permit(:first_name, :last_name, :phone, :address_line1, :address_line2,
                                 :city, :postal_code, :province_id)
  end
end
