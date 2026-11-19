class CreateStoreTables < ActiveRecord::Migration[7.1]
  def change
    create_table :provinces do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.decimal :gst_rate, precision: 5, scale: 4, null: false, default: 0
      t.decimal :pst_rate, precision: 5, scale: 4, null: false, default: 0
      t.decimal :hst_rate, precision: 5, scale: 4, null: false, default: 0
      t.timestamps
      t.index :code, unique: true
    end

    create_table :users do |t|
      t.string :username, null: false
      t.string :email, null: false, default: ""
      t.string :encrypted_password, null: false, default: ""
      t.datetime :remember_created_at
      t.string :first_name
      t.string :last_name
      t.string :phone
      t.string :address_line1
      t.string :address_line2
      t.string :city
      t.string :postal_code
      t.references :province, foreign_key: true
      t.string :stripe_customer_id
      t.timestamps
      t.index :email, unique: true
      t.index "lower(username)", unique: true, name: "index_users_on_lower_username"
    end

    create_table :admin_users do |t|
      t.string :email, null: false, default: ""
      t.string :encrypted_password, null: false, default: ""
      t.datetime :remember_created_at
      t.string :name
      t.timestamps
      t.index :email, unique: true
    end

    create_table :categories do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.timestamps
      t.index :slug, unique: true
    end

    create_table :products do |t|
      t.string :name, null: false
      t.string :sku, null: false
      t.text :description, null: false
      t.decimal :price, precision: 10, scale: 2, null: false
      t.decimal :sale_price, precision: 10, scale: 2
      t.boolean :on_sale, null: false, default: false
      t.integer :stock_quantity, null: false, default: 0
      t.boolean :active, null: false, default: true
      t.timestamps
      t.index :sku, unique: true
    end

    create_table :product_categories do |t|
      t.references :product, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.timestamps
      t.index %i[product_id category_id], unique: true
    end

    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.references :province, null: false, foreign_key: true
      t.string :status, null: false, default: "unpaid"
      t.decimal :subtotal, precision: 10, scale: 2, null: false, default: 0
      t.decimal :gst_rate, precision: 5, scale: 4, null: false, default: 0
      t.decimal :pst_rate, precision: 5, scale: 4, null: false, default: 0
      t.decimal :hst_rate, precision: 5, scale: 4, null: false, default: 0
      t.decimal :gst_amount, precision: 10, scale: 2, null: false, default: 0
      t.decimal :pst_amount, precision: 10, scale: 2, null: false, default: 0
      t.decimal :hst_amount, precision: 10, scale: 2, null: false, default: 0
      t.decimal :total, precision: 10, scale: 2, null: false, default: 0
      t.string :shipping_name, null: false
      t.string :shipping_address, null: false
      t.string :shipping_city, null: false
      t.string :shipping_postal_code, null: false
      t.string :stripe_customer_id
      t.string :stripe_payment_id
      t.datetime :placed_at
      t.timestamps
      t.index :status
    end

    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :quantity, null: false
      t.decimal :unit_price, precision: 10, scale: 2, null: false
      t.timestamps
    end

    create_table :pages do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.text :content, null: false
      t.timestamps
      t.index :slug, unique: true
    end
  end
end
