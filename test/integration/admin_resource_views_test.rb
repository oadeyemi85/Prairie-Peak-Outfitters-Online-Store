require "test_helper"

class AdminResourceViewsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in AdminUser.create!(email: "staff@example.com", password: "password123")
  end

  test "admin can view slugged category, page, and product records" do
    category = Category.create!(name: "Paddling & Fishing")
    page = Page.create!(title: "Store Story", slug: "store-story", content: "Store story content.")
    product = Product.create!(name: "Test Product", sku: "TEST-1",
                              description: "A product for admin view testing.", price: 12, stock_quantity: 3)
    image_path = Rails.root.join("db/seeds/images/tents-shelter.jpg")
    File.open(image_path) do |image|
      product.image.attach(io: image, filename: "tents-shelter.jpg", content_type: "image/jpeg")
    end
    product.image.variant(:large).processed

    get admin_category_path(category)
    assert_response :success

    get admin_page_path(page)
    assert_response :success

    get admin_product_path(product)
    assert_response :success
  end
end
