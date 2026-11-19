require "test_helper"

class ProductImageFallbackTest < ActionDispatch::IntegrationTest
  test "product image tag includes a local fallback for failed attachments" do
    product = Product.create!(
      name: "Fallback Test Product",
      sku: "FALLBACK-1",
      description: "A product used to test the storefront image fallback.",
      price: 12,
      stock_quantity: 3
    )
    image_path = Rails.root.join("db/seeds/images/tents-shelter.jpg")
    File.open(image_path) do |image|
      product.image.attach(io: image, filename: "tents-shelter.jpg", content_type: "image/jpeg")
    end

    get product_path(product)

    assert_response :success
    assert_includes response.body, "onerror="
    assert_includes response.body, "product-image-fallback"
  end
end
