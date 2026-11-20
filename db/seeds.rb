# Idempotent seed script: provinces/territories with tax rates, an admin, categories,
# products with images, and the About/Contact pages.

require_relative "seeds/catalogue"

PROVINCES = [
  ["Alberta", "AB", 0.05, 0, 0], ["British Columbia", "BC", 0.05, 0.07, 0],
  ["Manitoba", "MB", 0.05, 0.07, 0], ["New Brunswick", "NB", 0, 0, 0.15],
  ["Newfoundland and Labrador", "NL", 0, 0, 0.15], ["Northwest Territories", "NT", 0.05, 0, 0],
  ["Nova Scotia", "NS", 0, 0, 0.14], ["Nunavut", "NU", 0.05, 0, 0],
  ["Ontario", "ON", 0, 0, 0.13], ["Prince Edward Island", "PE", 0, 0, 0.15],
  ["Quebec", "QC", 0.05, 0.09975, 0], ["Saskatchewan", "SK", 0.05, 0.06, 0],
  ["Yukon", "YT", 0.05, 0, 0]
].freeze

PROVINCES.each do |name, code, gst, pst, hst|
  Province.find_or_initialize_by(code: code).update!(name: name, gst_rate: gst, pst_rate: pst, hst_rate: hst)
end

admin_email = ENV.fetch("ADMIN_EMAIL", "admin@prairiepeak.example")
admin_password = ENV.fetch("ADMIN_PASSWORD", "password123")
if Rails.env.production? && !AdminUser.exists?(email: admin_email) && admin_password == "password123"
  raise "Set a unique ADMIN_PASSWORD before creating the production admin."
end

AdminUser.find_or_create_by!(email: admin_email) do |admin|
  admin.name = "Store Owner"
  admin.password = admin.password_confirmation = admin_password
end

CATEGORIES = {
  "Tents & Shelter" => "Wind-tested tents, tarps and shelters for prairie weather.",
  "Sleeping Gear" => "Sleeping bags, pads and liners rated for Manitoba nights.",
  "Packs & Bags" => "Daypacks, backpacking packs and dry bags.",
  "Footwear & Apparel" => "Boots, layers and outerwear for -40 to +30.",
  "Cooking & Hydration" => "Stoves, cookware and bottles for camp and trail.",
  "Paddling & Fishing" => "Paddles, PFDs and tackle for Whiteshell lakes."
}.freeze

categories = CATEGORIES.to_h do |name, description|
  [name, Category.find_or_create_by!(name: name) { |c| c.description = description }]
end

# [name, sku, categories, price, sale_price, stock, description]
PRODUCTS = [
  ["Whiteshell 2-Person Tent", "TNT-001", ["Tents & Shelter"], 289.99, nil, 12,
   "A freestanding three-season tent with a full rainfly and two vestibules, built to shrug off prairie crosswinds."],
  ["Riding Mountain 4-Person Tent", "TNT-002", ["Tents & Shelter"], 429.99, 379.99, 8,
   "Roomy family tent with two doors, a gear loft and taped seams for long weekends at the lake."],
  ["Shield Ultralight Tarp 10x10", "TNT-003", ["Tents & Shelter"], 119.99, nil, 20,
   "Silnylon tarp with reinforced tie-outs for a lightweight rain shelter or sun shade."],
  ["Polar -30C Sleeping Bag", "SLP-001", ["Sleeping Gear"], 349.99, nil, 10,
   "Down-filled mummy bag rated to -30C with a draft collar and zip baffle for winter camping."],
  ["Summer Loft 5C Sleeping Bag", "SLP-002", ["Sleeping Gear"], 149.99, 119.99, 18,
   "Synthetic three-season bag that packs small and stays warm even when damp."],
  ["Self-Inflating Sleeping Pad", "SLP-003", ["Sleeping Gear"], 89.99, nil, 25,
   "Three-centimetre self-inflating pad with an R-value of 3.5 for cold ground."],
  ["Merino Sleeping Bag Liner", "SLP-004", ["Sleeping Gear"], 74.99, nil, 15,
   "Soft merino liner that adds about five degrees of warmth and keeps your bag clean."],
  ["Trailhead 65L Backpack", "PCK-001", ["Packs & Bags"], 259.99, nil, 9,
   "Adjustable-torso backpacking pack with a ventilated back panel and rain cover included."],
  ["Daybreak 24L Daypack", "PCK-002", ["Packs & Bags"], 79.99, 64.99, 30,
   "Lightweight daypack with hip belt pockets and a hydration sleeve for day hikes."],
  ["Roll-Top Dry Bag 20L", "PCK-003", ["Packs & Bags", "Paddling & Fishing"], 29.99, nil, 40,
   "Waterproof roll-top bag that keeps clothes and electronics dry on the canoe."],
  ["Prairie Trail Hiking Boots", "FTW-001", ["Footwear & Apparel"], 199.99, nil, 14,
   "Waterproof leather-and-mesh boots with a cushioned midsole and grippy lugged sole."],
  ["Arctic Insulated Winter Boots", "FTW-002", ["Footwear & Apparel"], 229.99, 189.99, 11,
   "Felt-lined winter boots rated to -40C with a removable liner and steel shank."],
  ["Merino Base Layer Top", "APP-001", ["Footwear & Apparel"], 99.99, nil, 22,
   "Midweight merino base layer that wicks moisture and resists odour on multi-day trips."],
  ["Windproof Shell Jacket", "APP-002", ["Footwear & Apparel"], 179.99, nil, 16,
   "Breathable three-layer shell with an adjustable hood and pit zips for changing conditions."],
  ["Trapper Knit Mitts", "APP-003", ["Footwear & Apparel"], 44.99, 34.99, 35,
   "Warm knit mitts with a soft insulated lining for long days on the ice."],
  ["Two-Burner Camp Stove", "CKH-001", ["Cooking & Hydration"], 139.99, nil, 13,
   "Propane camp stove with wind guards and adjustable burners for real cooking at the campsite."],
  ["Pocket Rocket Trail Stove", "CKH-002", ["Cooking & Hydration"], 59.99, nil, 28,
   "Compact canister stove that boils a litre of water in under four minutes."],
  ["Nesting Cookware Set", "CKH-003", ["Cooking & Hydration"], 69.99, 54.99, 19,
   "Hard-anodized pot, pan and lid set that nests together with room for a fuel canister."],
  ["Insulated Steel Water Bottle 1L", "CKH-004", ["Cooking & Hydration"], 39.99, nil, 50,
   "Double-walled stainless bottle that keeps drinks cold for 24 hours or hot for 12."],
  ["Portable Trail Water Filter", "CKH-005", ["Cooking & Hydration"], 109.99, nil, 12,
   "Compact hand-pump filter for lake water that removes bacteria and protozoa."],
  ["Lightweight Canoe Paddle", "PAD-001", ["Paddling & Fishing"], 94.99, nil, 17,
   "Bent-shaft carbon paddle that stays light and comfortable through a full day on the water."],
  ["Type III Life Jacket (PFD)", "PAD-002", ["Paddling & Fishing"], 119.99, nil, 21,
   "Comfortable Canadian-approved PFD with large armholes and adjustable straps."],
  ["Walleye Tackle Starter Kit", "PAD-003", ["Paddling & Fishing"], 49.99, 39.99, 24,
   "Jigs, leaders and spinners picked by our staff for walleye on the Red River."]
].freeze

PRODUCT_IMAGES = {
  "TNT-001" => "tnt-001-two-person-tent.jpg",
  "TNT-002" => "tnt-002-family-tent.jpg",
  "TNT-003" => "tnt-003-tarp.jpg",
  "SLP-001" => "slp-001-mummy-bag.jpg",
  "SLP-002" => "slp-002-summer-bag.jpg",
  "SLP-003" => "slp-003-sleeping-pad.jpg",
  "SLP-004" => "slp-004-sleeping-liner.jpg",
  "PCK-001" => "pck-001-hiking-backpack.jpg",
  "PCK-002" => "pck-002-daypack.jpg",
  "PCK-003" => "pck-003-rolltop-dry-bag.jpg",
  "FTW-001" => "hiking-boots-wes.jpg",
  "FTW-002" => "ftw-002-winter-boots.jpg",
  "APP-001" => "app-001-base-layer.jpg",
  "APP-002" => "app-002-shell-jacket.jpg",
  "APP-003" => "app-003-red-knit-mitts.jpg",
  "CKH-001" => "ckh-001-two-burner-stove.jpg",
  "CKH-002" => "ckh-002-trail-stove.jpg",
  "CKH-003" => "ckh-003-cookware.jpg",
  "CKH-004" => "ckh-004-water-bottle.jpg",
  "CKH-005" => "ckh-005-water-filter.jpg",
  "PAD-001" => "pad-001-canoe-paddle.jpg",
  "PAD-002" => "pad-002-life-jacket.jpg",
  "PAD-003" => "pad-003-fishing-tackle.jpg"
}.freeze

seed_products = PRODUCTS.map { |product| product + [PRODUCT_IMAGES.fetch(product[1])] } + ADDITIONAL_PRODUCTS

seed_products.each_with_index do |(name, sku, cats, price, sale, stock, description, image_name), index|
  product = Product.find_or_initialize_by(sku: sku)
  product.assign_attributes(name: name, description: description, price: price, sale_price: sale,
                            on_sale: sale.present?, stock_quantity: stock, active: true,
                            categories: cats.map { |c| categories.fetch(c) })
  unless product.image.attached? && product.image.filename.to_s == image_name
    image_path = Rails.root.join("db/seeds/images/#{image_name}")
    File.open(image_path) do |image|
      product.image.attach(io: image, filename: image_name, content_type: "image/jpeg")
      product.save!
    end
  end
  product.save!

  # Spread timestamps so the "New" and "Recently updated" filters each have results.
  created = index < 6 ? 1.day.ago : 30.days.ago
  updated = index.between?(6, 11) ? 1.day.ago : created
  product.update_columns(created_at: created, updated_at: updated)
end

{
  "about" => ["About Prairie Peak Outfitters",
              [
                "Prairie Peak Outfitters has been Winnipeg's independent outdoor-gear shop since 2011.\n\n",
                "Our 14-person team tests gear in the Whiteshell, Riding Mountain and the Canadian Shield, ",
                "and we only sell what we would take on our own trips."
              ].join],
  "contact" => ["Contact Us",
                [
                  "Prairie Peak Outfitters\nWinnipeg, Manitoba\n\nPhone: 204-555-0142\n",
                  "Email: hello@prairiepeak.example\n\nStore hours: Monday to Saturday 10am to 6pm, Sunday 12pm to 5pm."
                ].join]
}.each do |slug, (title, content)|
  Page.find_or_create_by!(slug: slug) do |page|
    page.title = title
    page.content = content
  end
end

Rails.logger.info("Seeded #{Province.count} provinces, #{Category.count} categories, #{Product.count} products.")
