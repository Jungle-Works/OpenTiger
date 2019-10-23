# == Schema Information
#
# Table name: razorpay_orders
#
#  id                :integer          not null, primary key
#  razorpay_order_id :string(255)
#  community_id      :integer
#  amount            :integer
#  currency          :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class RazorpayOrder < ApplicationRecord

end
