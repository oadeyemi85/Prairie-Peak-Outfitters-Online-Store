ActiveAdmin.register User do
  actions :index, :show

  filter :username
  filter :email
  filter :province

  controller do
    def scoped_collection
      super.includes(:province, orders: { order_items: :product })
    end
  end

  index do
    id_column
    column :username
    column :email
    column :province
    column("Orders") { |u| u.orders.size }
    column("Total spent") { |u| number_to_currency(u.orders.reject(&:unpaid?).sum(&:total)) }
    actions
  end

  show do
    attributes_table do
      row :username
      row :email
      row :phone
      row("Address") { |u| [u.address_line1, u.address_line2, u.city, u.province&.code, u.postal_code].compact_blank.join(", ") }
      row :stripe_customer_id
    end
    panel "Orders" do
      table_for user.orders.order(created_at: :desc) do
        column("Order") { |o| link_to "##{o.id}", admin_order_path(o) }
        column :status
        column("Products") { |o| o.order_items.map { |i| "#{i.quantity} x #{i.product.name}" }.join(", ") }
        column("Taxes") { |o| number_to_currency(o.tax_total) }
        column("Grand total") { |o| number_to_currency(o.total) }
      end
    end
  end
end
