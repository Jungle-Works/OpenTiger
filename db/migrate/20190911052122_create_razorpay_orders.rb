class CreateRazorpayOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :razorpay_orders do |t|
      t.string :razorpay_order_id 
      t.integer :community_id 
      t.integer :amount 
      t.string :currency 
      t.timestamps
    end
  end
end
