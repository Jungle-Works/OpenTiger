# == Schema Information
#
# Table name: razorpay_api_logs
#
#  id             :integer          not null, primary key
#  payment_id     :string(255)
#  transaction_id :string(255)
#  api_response   :text(65535)
#  action         :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class RazorpayApiLog < ApplicationRecord
end
