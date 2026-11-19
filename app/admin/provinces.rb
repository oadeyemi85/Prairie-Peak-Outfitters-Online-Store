ActiveAdmin.register Province do
  permit_params :name, :code, :gst_rate, :pst_rate, :hst_rate

  actions :index, :show, :new, :create, :edit, :update

  index do
    id_column
    column :name
    column :code
    column :gst_rate
    column :pst_rate
    column :hst_rate
    actions
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :name
      f.input :code
      f.input :gst_rate, hint: "Decimal, e.g. 0.05 for 5%"
      f.input :pst_rate
      f.input :hst_rate, hint: "Use HST only for harmonized provinces; set GST and PST to 0"
    end
    f.actions
  end
end
