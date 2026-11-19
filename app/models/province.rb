class Province < ApplicationRecord
  has_many :users, dependent: :restrict_with_error
  has_many :orders, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true, length: { maximum: 60 }
  validates :code, presence: true, uniqueness: true, length: { is: 2 }
  validates :gst_rate, :pst_rate, :hst_rate,
            presence: true,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }

  def to_s
    name
  end

  def tax_label
    if hst_rate.positive?
      "HST #{format_rate(hst_rate)}"
    else
      [("GST #{format_rate(gst_rate)}" if gst_rate.positive?),
       ("PST #{format_rate(pst_rate)}" if pst_rate.positive?)].compact.join(" + ")
    end
  end

  private

  def format_rate(rate)
    "#{(rate * 100).to_f.round(3)}%"
  end
end
