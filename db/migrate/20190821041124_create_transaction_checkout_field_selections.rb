class CreateTransactionCheckoutFieldSelections < ActiveRecord::Migration[5.1]
  def change
    create_table :transaction_checkout_field_selections do |t|
      t.integer :transaction_checkout_field_id
      t.string :label, default: ""
      t.string :value, default: ""
      t.text :description
      t.integer :community_id
      t.integer :transaction_id

      t.timestamps
    end
  end
end
