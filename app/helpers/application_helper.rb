module ApplicationHelper
  def money(amount)
    number_to_currency(amount)
  end

  def product_image(product, variant, **options)
    if product.image.attached?
      image_tag product.image.variant(variant),
                **options.reverse_merge(
                  alt: product.name,
                  onerror: "this.onerror=null;this.src='#{asset_path('product-image-fallback.svg')}'"
                )
    else
      tag.div("Image unavailable", class: "placeholder-img #{options[:class]}")
    end
  end

  def flash_class(type)
    { "notice" => "success", "alert" => "danger", "cart_notice" => "info" }.fetch(type.to_s, "secondary")
  end
end
