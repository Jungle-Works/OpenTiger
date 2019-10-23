# == Schema Information
#
# Table name: transaction_checkout_fields
#
#  id             :integer          not null, primary key
#  field_type     :string(255)      default("")
#  title          :string(255)      default("")
#  value          :text(65535)
#  community_id   :integer
#  transaction_id :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class TransactionCheckoutField < ApplicationRecord

    belongs_to :community 
    has_many :transaction_checkout_field_selections
end
