class CheckoutsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_cart
  before_action :require_address, only: %i[new create]

  def new
    @order = Order.build_for(current_user, current_cart.lines)
    set_breadcrumbs(["Cart", cart_path], ["Checkout", nil])
  end

  def create
    order = Order.build_for(current_user, current_cart.lines)
    unless order.save
      redirect_to cart_path, alert: order.errors.full_messages.to_sentence
      return
    end

    session_url = create_stripe_session(order)
    redirect_to session_url, allow_other_host: true
  rescue Stripe::StripeError => e
    Rails.logger.error("Stripe error: #{e.message}")
    order&.destroy
    redirect_to cart_path, alert: "We could not start the payment. Please try again."
  end

  def success
    order = current_user.orders.find(params[:order_id])
    stripe_session = Stripe::Checkout::Session.retrieve(params[:session_id])

    if stripe_session.metadata["order_id"] == order.id.to_s && stripe_session.payment_status == "paid"
      order.mark_paid!(stripe_session.customer, stripe_session.payment_intent)
      current_cart.clear
      redirect_to order_path(order), notice: "Payment received. Thank you for your order!"
    else
      redirect_to cart_path, alert: "We could not confirm your payment."
    end
  rescue Stripe::StripeError => e
    Rails.logger.error("Stripe error: #{e.message}")
    redirect_to cart_path, alert: "We could not confirm your payment."
  end

  def cancel
    redirect_to cart_path, alert: "Payment was cancelled. Your cart is still saved."
  end

  private

  def require_cart
    redirect_to cart_path, alert: "Your cart is empty." if current_cart.empty? && action_name != "success"
  end

  def require_address
    return if current_user.address_complete?

    session[:return_to_checkout] = true
    redirect_to edit_account_path, alert: "Please complete your address (including province) before checking out."
  end

  def create_stripe_session(order)
    Stripe::Checkout::Session.create(
      mode: "payment",
      customer: stripe_customer_id,
      line_items: stripe_line_items(order),
      metadata: { order_id: order.id },
      success_url: "#{success_checkout_url}?order_id=#{order.id}&session_id={CHECKOUT_SESSION_ID}",
      cancel_url: cancel_checkout_url
    ).url
  end

  def stripe_customer_id
    return current_user.stripe_customer_id if current_user.stripe_customer_id.present?

    customer = Stripe::Customer.create(email: current_user.email, name: current_user.full_name)
    current_user.update_column(:stripe_customer_id, customer.id)
    customer.id
  end

  def stripe_line_items(order)
    product_lines = order.order_items.map do |item|
      stripe_line(item.product.name, item.unit_price, item.quantity)
    end
    tax_lines = order.tax_lines.map do |label, rate, amount|
      stripe_line("#{label} (#{(rate * 100).to_f.round(3)}%)", amount, 1)
    end
    product_lines + tax_lines
  end

  def stripe_line(name, amount, quantity)
    {
      quantity: quantity,
      price_data: { currency: "cad", unit_amount: (amount * 100).round.to_i, product_data: { name: name } }
    }
  end
end
