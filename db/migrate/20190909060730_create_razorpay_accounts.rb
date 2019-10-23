class CreateRazorpayAccounts < ActiveRecord::Migration[5.1]
  def change
    create_table :razorpay_accounts do |t|
      t.string :person_id
      t.integer :community_id
      t.string :razorpay_account_id

      t.timestamps
    end
  end
end
