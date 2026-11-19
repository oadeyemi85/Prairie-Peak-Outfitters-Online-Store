require "test_helper"

class OrderTest < ActiveSupport::TestCase
  setup do
    @manitoba = Province.create!(name: "Manitoba", code: "MB", gst_rate: 0.05, pst_rate: 0.07, hst_rate: 0)
    @user = User.create!(username: "tester", email: "t@example.com", password: "password123",
                         first_name: "T", last_name: "Ester", address_line1: "1 Main St", city: "Winnipeg",
                         postal_code: "R3C 0A5", province: @manitoba)
    @product = Product.create!(name: "Test Tent", sku: "TST-1", description: "A tent for testing things.",
                               price: 100, stock_quantity: 5)
  end

  test "calculates provincial taxes" do
    order = Order.build_for(@user, [[@product, 2]])
    assert_equal 200, order.subtotal
    assert_equal 10, order.gst_amount
    assert_equal 14, order.pst_amount
    assert_equal 224, order.total
  end

  test "price and tax changes do not alter saved orders" do
    order = Order.build_for(@user, [[@product, 1]])
    order.save!
    @product.update!(price: 500)
    @manitoba.update!(pst_rate: 0.1)
    order.reload
    assert_equal 100, order.order_items.first.unit_price
    assert_equal 0.07, order.pst_rate
    assert_equal 112, order.total
  end

  test "mark_paid! sets status and decrements stock" do
    order = Order.build_for(@user, [[@product, 2]])
    order.save!
    order.mark_paid!("cus_1", "pi_1")
    assert order.paid?
    assert_equal 3, @product.reload.stock_quantity
  end

  test "product requires a sale price lower than price" do
    @product.assign_attributes(on_sale: true, sale_price: 150)
    assert_not @product.valid?
  end
end
