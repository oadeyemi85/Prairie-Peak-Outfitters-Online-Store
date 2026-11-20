require "test_helper"

class AdventureStorefrontTest < ActionDispatch::IntegrationTest
  test "home page links each available adventure slide to its category" do
    HomeController::HERO_SLIDES.each do |slide|
      Category.create!(name: slide[:slug].tr("-", " ").titleize, slug: slide[:slug])
    end

    get root_path

    assert_response :success
    assert_select "#adventureCarousel .carousel-item", 6
    HomeController::HERO_SLIDES.each do |slide|
      assert_select "#adventureCarousel a[href=?]", category_path(slide[:slug]), 1
    end
    assert_select "#adventureCarousel .adventure-pause", 1
  end

  test "home page remains usable when a slide category is missing" do
    Category.create!(name: "Packs & Bags", slug: "packs-bags")

    get root_path

    assert_response :success
    assert_select "#adventureCarousel .carousel-item", 1
    assert_select "#adventureCarousel a[href=?]", category_path("packs-bags"), 1
    assert_select "#adventureCarousel .adventure-pause", 0
  end

  test "category pages show up to twelve products and paginate the rest" do
    category = Category.create!(name: "Test Camping", slug: "test-camping")
    13.times do |index|
      category.products.create!(name: format("Test Tent %02d", index), sku: "TEST-TENT-#{index}",
                                description: "A camping tent for the pagination test.", price: 50,
                                stock_quantity: 1)
    end

    get category_path(category)
    assert_response :success
    assert_select ".product-card", 12

    get category_path(category, page: 2)
    assert_response :success
    assert_select ".product-card", 1
  end
end
