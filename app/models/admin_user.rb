class AdminUser < ApplicationRecord
  devise :database_authenticatable, :rememberable, :validatable, authentication_keys: [:email]

  validates :name, length: { maximum: 80 }, allow_blank: true
end
