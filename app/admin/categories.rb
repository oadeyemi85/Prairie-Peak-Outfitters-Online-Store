ActiveAdmin.register Category do
  permit_params :name, :slug, :description

  controller do
    def find_resource
      scoped_collection.find_by(slug: params[:id]) || scoped_collection.find(params[:id])
    end
  end

  filter :name
  filter :slug

  index do
    selectable_column
    id_column
    column :name
    column :slug
    column("Products") { |c| c.products.count }
    actions
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :name
      f.input :slug, hint: "Leave blank to generate from the name"
      f.input :description
    end
    f.actions
  end
end
