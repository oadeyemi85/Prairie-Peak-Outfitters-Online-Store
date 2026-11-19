ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    columns do
      column do
        panel "Recent orders" do
          table_for Order.includes(:user).order(created_at: :desc).limit(10) do
            column("Order") { |o| link_to "##{o.id}", admin_order_path(o) }
            column("Customer") { |o| o.user.username }
            column("Status") { |o| status_tag o.status }
            column("Total") { |o| number_to_currency(o.total) }
          end
        end
      end
      column do
        panel "Store at a glance" do
          ul do
            li "Products: #{Product.count}"
            li "Categories: #{Category.count}"
            li "Customers: #{User.count}"
            li "Paid orders awaiting shipment: #{Order.paid.count}"
          end
        end
      end
    end
  end
end
