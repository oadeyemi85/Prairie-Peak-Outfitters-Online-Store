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

  test "admin can open new and edit product forms" do
    product = Product.create!(name: "Test Product", sku: "TEST-1",
                              description: "A product for admin form testing.", price: 12, stock_quantity: 3)

    [new_admin_product_path, edit_admin_product_path(product)].each do |path|
      get path
      assert_response :success
      assert_select 'input[name="product[price]"][min="0.01"][max="99999.99"][step="0.01"]'
      assert_select 'input[type="file"][name="product[image]"]'
    end
  end

  test "admin can update a product image" do
    product = Product.create!(name: "Test Product", sku: "TEST-1",
                              description: "A product for admin image testing.", price: 12, stock_quantity: 3)
    image = Rack::Test::UploadedFile.new(Rails.root.join("db/seeds/images/tents-shelter.jpg"), "image/jpeg")

    patch admin_product_path(product), params: { product: { image: image } }

    assert_redirected_to admin_product_path(product)
    assert product.reload.image.attached?
    assert_equal "tents-shelter.jpg", product.image.filename.to_s
  end

  test "admin can create a product with an image and category" do
    category = Category.create!(name: "Demo Gear")
    image = Rack::Test::UploadedFile.new(Rails.root.join("db/seeds/images/tents-shelter.jpg"), "image/jpeg")

    assert_difference "Product.count", 1 do
      post admin_products_path, params: {
        product: { name: "Test Product", sku: "TEST-1",
                   description: "A product for admin creation testing.", price: 12, stock_quantity: 3,
                   category_ids: [category.id], image: image }
      }
    end

    product = Product.find_by!(sku: "TEST-1")
    assert_redirected_to admin_product_path(product)
    assert product.image.attached?
    assert_includes product.categories, category
  end

  test "invalid product with a new image shows validation errors instead of crashing" do
    category = Category.create!(name: "Demo Gear")
    image = Rack::Test::UploadedFile.new(Rails.root.join("db/seeds/images/tents-shelter.jpg"), "image/jpeg")

    assert_no_difference "Product.count" do
      post admin_products_path, params: {
        product: { name: "Test Product", sku: "INVALID SKU",
                   description: "A product for admin creation testing.", price: 12, stock_quantity: 3,
                   category_ids: [category.id], image: image }
      }
    end

    assert_response :success
    assert_select "#product_sku_input .inline-errors", text: /invalid/
    assert_select 'input[name="product[category_ids][]"][value=?][checked]', category.id.to_s
    assert_match "Please select the image again before submitting.", response.body
  end

  test "invalid product update with a new image shows validation errors" do
    product = Product.create!(name: "Test Product", sku: "TEST-1",
                              description: "A product for admin image testing.", price: 12, stock_quantity: 3)
    image = Rack::Test::UploadedFile.new(Rails.root.join("db/seeds/images/tents-shelter.jpg"), "image/jpeg")

    patch admin_product_path(product), params: { product: { sku: "INVALID SKU", image: image } }

    assert_response :success
    assert_select "#product_sku_input .inline-errors", text: /invalid/
    assert_match "Please select the image again before submitting.", response.body
    assert_equal "TEST-1", product.reload.sku
    assert_not product.image.attached?
  end
end
