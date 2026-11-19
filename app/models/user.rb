class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :rememberable, :validatable

  CANADIAN_POSTAL_CODE = /\A[A-Za-z]\d[A-Za-z][ -]?\d[A-Za-z]\d\z/

  attr_accessor :login

  belongs_to :province, optional: true
  has_many :orders, dependent: :restrict_with_error

  validates :username, presence: true,
                       uniqueness: { case_sensitive: false },
                       format: { with: /\A[a-zA-Z0-9_]{3,30}\z/,
                                 message: "must be 3-30 letters, numbers or underscores" }
  validates :first_name, :last_name, length: { maximum: 60 }, allow_blank: true
  validates :phone, format: { with: /\A[0-9 ()+.-]{7,20}\z/ }, allow_blank: true
  validates :address_line1, :address_line2, :city, length: { maximum: 120 }, allow_blank: true
  validates :postal_code, format: { with: CANADIAN_POSTAL_CODE, message: "must be a valid Canadian postal code" },
                          allow_blank: true
  # Required before checkout, not at sign-up.
  validates :first_name, :last_name, :address_line1, :city, :postal_code, :province_id,
            presence: true, on: :checkout

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    login = conditions.delete(:login)
    if login
      where(conditions.to_h)
        .where("lower(username) = :v OR lower(email) = :v", v: login.to_s.strip.downcase).first
    elsif conditions.key?(:username) || conditions.key?(:email)
      where(conditions.to_h).first
    end
  end

  def full_name
    [first_name, last_name].compact_blank.join(" ").presence || username
  end

  def address_complete?
    valid?(:checkout)
  end
end
