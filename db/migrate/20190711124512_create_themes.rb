class CreateThemes < ActiveRecord::Migration[5.1]
  def change
    create_table :themes do |t|
      t.string :title, default: ""
      t.string :description, default: ""
      t.text :content, limit: 16.megabytes - 1, null: false
      t.boolean :is_paid, default: false
      t.integer :price_in_cents, default: 0
      t.string :price_currency, default: ""

      t.timestamps
    end
  end
end
