class Product < ApplicationRecord
  RECENT_WINDOW = 3.days

  has_many :product_categories, dependent: :destroy
  has_many :categories, through: :product_categories
  has_many :order_items, dependent: :restrict_with_error
  has_many :orders, through: :order_items

  has_one_attached :image do |attachable|
    attachable.variant :thumb, resize_to_fill: [480, 480]
    attachable.variant :large, resize_to_limit: [840, 840]
  end

  validates :name, presence: true, length: { minimum: 3, maximum: 120 }
  validates :sku, presence: true, uniqueness: true, format: { with: /\A[A-Za-z0-9-]+\z/ }
  validates :description, presence: true, length: { minimum: 10, maximum: 5000 }
  validates :price, presence: true, numericality: { greater_than: 0, less_than: 100_000 }
  validates :sale_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :sale_price, presence: true, if: :on_sale?
  validates :stock_quantity, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :on_sale, :active, inclusion: { in: [true, false] }
  validate :sale_price_below_price
  validate :image_is_an_image

  scope :active, -> { where(active: true) }
  scope :on_sale, -> { where(on_sale: true) }
  scope :recently_added, -> { where(created_at: RECENT_WINDOW.ago..) }
  # "New" products are excluded so the two filters never overlap.
  scope :recently_updated, -> { where(updated_at: RECENT_WINDOW.ago..).where(created_at: ...RECENT_WINDOW.ago) }
  scope :in_category, ->(category_id) { joins(:product_categories).where(product_categories: { category_id: category_id }) }
  scope :search, lambda { |keyword|
    if keyword.present?
      pattern = "%#{sanitize_sql_like(keyword.strip)}%"
      where("products.name ILIKE :p OR products.description ILIKE :p", p: pattern)
    end
  }

  def current_price
    on_sale? && sale_price.present? ? sale_price : price
  end

  def in_stock?
    stock_quantity.positive?
  end

  def related_products(limit = 4)
    Product.active.in_category(category_ids).where.not(id: id).distinct.limit(limit)
  end

  def to_s
    name
  end

  private

  def sale_price_below_price
    return unless on_sale? && sale_price.present? && price.present?

    errors.add(:sale_price, "must be lower than the regular price") if sale_price >= price
  end

  def image_is_an_image
    return unless image.attached?

    errors.add(:image, "must be a JPEG, PNG, GIF or WebP") unless image.content_type.in?(%w[image/jpeg image/png image/gif image/webp])
    errors.add(:image, "must be smaller than 5 MB") if image.byte_size > 5.megabytes
  end
end
