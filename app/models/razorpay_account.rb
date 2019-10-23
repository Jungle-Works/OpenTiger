# == Schema Information
#
# Table name: razorpay_accounts
#
#  id                  :integer          not null, primary key
#  person_id           :string(255)
#  community_id        :integer
#  razorpay_account_id :string(255)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class RazorpayAccount < ApplicationRecord
    belongs_to :community
    belongs_to :person

    VALID_BUSINESS_TYPES = ["llp", "ngo", "other", "individual", "partnership", "proprietorship", "public_limited", "private_limited",  "trust", "society", "not_yet_registered", "educational_institutes"]
end
