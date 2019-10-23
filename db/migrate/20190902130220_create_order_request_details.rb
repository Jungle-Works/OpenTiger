class CreateOrderRequestDetails < ActiveRecord::Migration[5.1]
  def change
    create_table :order_request_details do |t|
      t.integer :listing_id
      t.string :app_session_token
      t.text :order_detail

      t.timestamps
    end
  end
end
