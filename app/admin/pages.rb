# Edits the About and Contact pages through a custom web form.
ActiveAdmin.register Page do
  permit_params :title, :slug, :content

  actions :index, :show, :new, :create, :edit, :update

  controller do
    def find_resource
      scoped_collection.find_by(slug: params[:id]) || scoped_collection.find(params[:id])
    end
  end

  index do
    id_column
    column :title
    column :slug
    column :updated_at
    actions
  end

  form do |f|
    f.semantic_errors
    f.inputs "Page content" do
      f.input :title
      f.input :slug, hint: "about or contact for the main pages"
      f.input :content, as: :text, input_html: { rows: 15 }
    end
    f.actions
  end
end
