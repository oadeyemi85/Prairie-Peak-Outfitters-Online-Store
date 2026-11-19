ActiveAdmin.register Order do
  actions :index, :show

  scope :all, default: true
  scope :unpaid
  scope :paid
  scope :shipped

  filter :user_username, as: :string, label: "Customer username"
  filter :status, as: :select, collection: Order.statuses.keys
  filter :created_at

  controller do
    def scoped_collection
      super.includes(:user, order_items: :product)
    end
  end

  index do
    id_column
    column("Customer") { |o| link_to o.user.full_name, admin_user_path(o.user) }
    column :status do |o|
      status_tag o.status
    end
    column("Products ordered") do |o|
      safe_join(o.order_items.map { |i| "#{i.quantity} x #{i.product.name} @ #{number_to_currency(i.unit_price)}" }, tag.br)
    end
    column("Taxes") { |o| number_to_currency(o.tax_total) }
    column("Grand total") { |o| number_to_currency(o.total) }
    column :created_at
    actions defaults: true do |o|
      link_to("Mark shipped", ship_admin_order_path(o), method: :put) if o.paid?
    end
  end

  show do
    attributes_table do
      row :id
      row("Customer") { |o| link_to o.user.full_name, admin_user_path(o.user) }
      row :status
      row("Ship to") { |o| "#{o.shipping_name}, #{o.shipping_address}, #{o.shipping_city} #{o.province.code} #{o.shipping_postal_code}" }
      row :stripe_customer_id
      row :stripe_payment_id
      row :placed_at
    end
    panel "Items" do
      table_for order.order_items do
        column("Product") { |i| i.product.name }
        column :quantity
        column("Unit price (at purchase)") { |i| number_to_currency(i.unit_price) }
        column("Line total") { |i| number_to_currency(i.line_total) }
      end
    end
    panel "Totals" do
      attributes_table_for order do
        row("Subtotal") { |o| number_to_currency(o.subtotal) }
        row("GST") { |o| "#{number_to_currency(o.gst_amount)} (#{(o.gst_rate * 100).to_f}%)" }
        row("PST") { |o| "#{number_to_currency(o.pst_amount)} (#{(o.pst_rate * 100).to_f}%)" }
        row("HST") { |o| "#{number_to_currency(o.hst_amount)} (#{(o.hst_rate * 100).to_f}%)" }
        row("Grand total") { |o| number_to_currency(o.total) }
      end
    end
  end

  action_item :ship, only: :show, if: proc { resource.paid? } do
    link_to "Mark as shipped", ship_admin_order_path(resource), method: :put
  end

  member_action :ship, method: :put do
    if resource.mark_shipped!
      redirect_to admin_order_path(resource), notice: "Order marked as shipped."
    else
      redirect_to admin_order_path(resource), alert: "Only paid orders can be shipped."
    end
  end

  batch_action :mark_shipped do |ids|
    batch_action_collection.where(id: ids).find_each(&:mark_shipped!)
    redirect_to collection_path, notice: "Paid orders marked as shipped."
  end
end
