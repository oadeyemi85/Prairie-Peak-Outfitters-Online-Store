class Order < ApplicationRecord
  belongs_to :user
  belongs_to :province
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items

  enum :status, { unpaid: "unpaid", paid: "paid", shipped: "shipped" }

  validates :subtotal, :gst_amount, :pst_amount, :hst_amount, :total,
            numericality: { greater_than_or_equal_to: 0 }
  validates :gst_rate, :pst_rate, :hst_rate,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }
  validates :shipping_name, :shipping_address, :shipping_city, presence: true, length: { maximum: 160 }
  validates :shipping_postal_code, presence: true, format: { with: User::CANADIAN_POSTAL_CODE }
  validates :order_items, presence: true

  # Builds an unsaved order from cart lines ([[product, qty], ...]).
  # Prices and tax rates are copied onto the order (never looked up later), so
  # future price/tax changes cannot alter historical orders.
  def self.build_for(user, lines)
    order = new(
      user: user,
      province: user.province,
      shipping_name: user.full_name,
      shipping_address: [user.address_line1, user.address_line2].compact_blank.join(", "),
      shipping_city: user.city,
      shipping_postal_code: user.postal_code
    )
    lines.each do |product, quantity|
      order.order_items.build(product: product, quantity: quantity, unit_price: product.current_price)
    end
    order.calculate_totals
    order
  end

  def calculate_totals
    self.subtotal = order_items.to_a.sum(&:line_total)
    calculate_tax(:gst)
    calculate_tax(:pst)
    calculate_tax(:hst)
    self.total = subtotal + gst_amount + pst_amount + hst_amount
  end

  def tax_total
    gst_amount + pst_amount + hst_amount
  end

  def tax_lines
    [["GST", gst_rate, gst_amount], ["PST", pst_rate, pst_amount], ["HST", hst_rate, hst_amount]]
      .select { |_label, _rate, amount| amount.positive? }
  end

  def mark_paid!(customer_id, payment_id)
    return if paid? || shipped?

    transaction do
      update!(status: :paid, stripe_customer_id: customer_id, stripe_payment_id: payment_id, placed_at: Time.current)
      order_items.includes(:product).find_each do |item|
        item.product.update_columns(stock_quantity: [item.product.stock_quantity - item.quantity, 0].max)
      end
    end
  end

  def mark_shipped!
    update!(status: :shipped) if paid?
  end

  private

  def calculate_tax(tax_type)
    rate = province ? province.public_send("#{tax_type}_rate") : public_send("#{tax_type}_rate")
    public_send("#{tax_type}_rate=", rate)
    public_send("#{tax_type}_amount=", (subtotal * rate).round(2))
  end
end
