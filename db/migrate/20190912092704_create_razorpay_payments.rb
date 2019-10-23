class CreateRazorpayPayments < ActiveRecord::Migration[5.1]
  def change
    create_table :razorpay_payments do |t|

      t.string    :payment_id  
      t.string    :order_id 
      t.string    :payer
      t.string    :merchant 
      t.integer   :transaction_id, null: false
      t.string    :currency, null: false, limit: 8
      t.integer   :order_total_cents, null: false
      t.integer   :fee_total_cents
      t.string    :payment_status, null: false, limit: 64
      
      t.timestamps
    end
  end
end
