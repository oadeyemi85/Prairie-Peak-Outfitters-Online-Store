ActiveAdmin.register Product do
  permit_params :name, :sku, :description, :price, :sale_price, :on_sale,
                :stock_quantity, :active, :image, category_ids: []

  filter :name
  filter :sku
  filter :categories
  filter :on_sale
  filter :active
  filter :created_at

  controller do
    def scoped_collection
      super.includes(:categories, image_attachment: :blob)
    end
  end

  index do
    selectable_column
    id_column
    column("Image") { |p| image_tag(p.image.variant(:thumb), height: 48) if p.image.attached? }
    column :name
    column :sku
    column("Categories") { |p| p.categories.map(&:name).join(", ") }
    column :price
    column :on_sale
    column :stock_quantity
    column :active
    actions
  end

  show do
    attributes_table do
      row :name
      row :sku
      row :description
      row :price
      row :sale_price
      row :on_sale
      row :stock_quantity
      row :active
      row("Categories") { |p| p.categories.map(&:name).join(", ") }
      row("Image") { |p| image_tag(p.image.variant(:large), width: 300) if p.image.attached? }
    end
  end

  # Categories are assigned through a checkbox list (category_ids), so staff never
  # touch the product_categories join table directly.
  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :name
      f.input :sku
      f.input :description
      f.input :price, min: 0.01, max: 99_999.99, step: 0.01
      f.input :on_sale
      f.input :sale_price
      f.input :stock_quantity
      f.input :active
      f.input :category_ids, as: :check_boxes, collection: Category.order(:name), label: "Categories"
      image_hint = if f.object.image.attached?
                     if f.object.image.blob.persisted?
                       image_tag(f.object.image.variant(:thumb), height: 80)
                     else
                       "Please select the image again before submitting."
                     end
                   end
      f.input :image, as: :file,
                      hint: image_hint
    end
    f.actions
  end
end
