class AddVerificationStatusToRazorpayAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :razorpay_accounts, :verification_status, :string
  end
end
