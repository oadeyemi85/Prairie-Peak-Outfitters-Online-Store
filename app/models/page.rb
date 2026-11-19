class Page < ApplicationRecord
  validates :title, presence: true, length: { maximum: 120 }
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9-]+\z/ }
  validates :content, presence: true, length: { maximum: 20_000 }

  def to_param
    slug
  end
end
