class HomeController < ApplicationController
  HERO_SLIDES = [
    { slug: "footwear-apparel", image: "footwear.jpg", title: "Find your own horizon",
      description: "Layers and footwear for every step." },
    { slug: "packs-bags", image: "packs.jpg", title: "Carry the adventure",
      description: "Packs built for the path ahead." },
    { slug: "tents-shelter", image: "tents.jpg", title: "Make the outdoors home",
      description: "Find your place under the open sky." },
    { slug: "sleeping-gear", image: "sleeping.jpg", title: "Rest beyond the road",
      description: "Sleep comfortably wherever the trail leads." },
    { slug: "cooking-hydration", image: "cooking.jpg", title: "Good food, great outdoors",
      description: "Camp kitchen essentials for the journey." },
    { slug: "paddling-fishing", image: "paddling.jpg", title: "Follow the water",
      description: "Gear up for days on the lake." }
  ].freeze

  def index
    scope = Product.active.with_attached_image
    @new_arrivals = scope.order(created_at: :desc).limit(8)
    @sale_products = scope.on_sale.limit(4)
    categories = nav_categories.index_by(&:slug)
    @hero_slides = HERO_SLIDES.filter_map do |slide|
      slide.merge(category: categories[slide[:slug]]) if categories.key?(slide[:slug])
    end
  end
end
