# Session-backed shopping cart: { "product_id" => quantity }.
class Cart
  MAX_PER_ITEM = 99

  def initialize(session)
    @session = session
    @session[:cart] ||= {}
  end

  def add(product, quantity = 1)
    set(product, current_quantity(product) + quantity.to_i)
  end

  def set(product, quantity)
    quantity = quantity.to_i.clamp(0, [product.stock_quantity, MAX_PER_ITEM].min)
    if quantity.zero?
      remove(product.id)
    else
      data[product.id.to_s] = quantity
    end
  end

  def remove(product_id)
    data.delete(product_id.to_s)
  end

  def clear
    @session[:cart] = {}
  end

  def current_quantity(product)
    data[product.id.to_s].to_i
  end

  def lines
    products = Product.active.with_attached_image.where(id: data.keys).index_by { |p| p.id.to_s }
    data.filter_map { |id, qty| [products[id], qty] if products[id] }
  end

  def count
    lines.sum { |_product, qty| qty }
  end

  def subtotal
    lines.sum { |product, qty| product.current_price * qty }
  end

  delegate :empty?, to: :lines

  private

  def data
    @session[:cart]
  end
end
