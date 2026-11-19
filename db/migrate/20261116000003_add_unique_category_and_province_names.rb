class AddUniqueCategoryAndProvinceNames < ActiveRecord::Migration[7.1]
  def change
    add_index :categories, "lower(name)", unique: true, name: "index_categories_on_lower_name"
    add_index :provinces, :name, unique: true
  end
end
