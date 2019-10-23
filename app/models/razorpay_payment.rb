# == Schema Information
#
# Table name: razorpay_payments
#
#  id                :integer          not null, primary key
#  payment_id        :string(255)
#  order_id          :string(255)
#  payer             :string(255)
#  merchant          :string(255)
#  transaction_id    :integer          not null
#  currency          :string(8)        not null
#  order_total_cents :integer          not null
#  fee_total_cents   :integer
#  payment_status    :string(64)       not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class RazorpayPayment < ApplicationRecord
    belongs_to :t
end
