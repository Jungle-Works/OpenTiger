class CreateRazorpayApiLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :razorpay_api_logs do |t|
      t.string :payment_id
      t.string :transaction_id
      t.text :api_response
      t.string :action

      t.timestamps
    end
  end
end
