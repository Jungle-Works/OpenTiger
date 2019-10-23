class CreateTransactionCheckoutFields < ActiveRecord::Migration[5.1]
  def change
    create_table :transaction_checkout_fields do |t|
      t.string :field_type, default: ""
      t.string :title, default: ""
      t.text :value
      t.integer :community_id
      t.integer :transaction_id
      t.timestamps
    end
  end
end
