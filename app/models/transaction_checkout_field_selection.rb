# == Schema Information
#
# Table name: transaction_checkout_field_selections
#
#  id                            :integer          not null, primary key
#  transaction_checkout_field_id :integer
#  label                         :string(255)      default("")
#  value                         :string(255)      default("")
#  description                   :text(65535)
#  community_id                  :integer
#  transaction_id                :integer
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#

class TransactionCheckoutFieldSelection < ApplicationRecord

    belongs_to :community 
    belongs_to :transaction_checkout_field
end
