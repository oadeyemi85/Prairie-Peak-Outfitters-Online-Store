class Category < ApplicationRecord
  has_many :product_categories, dependent: :destroy
  has_many :products, through: :product_categories

  before_validation :set_slug

  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 80 }
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9-]+\z/ }
  validates :description, length: { maximum: 1000 }, allow_blank: true

  def to_param
    slug
  end

  def to_s
    name
  end

  private

  def set_slug
    self.slug = name.to_s.parameterize if slug.blank?
  end
end
