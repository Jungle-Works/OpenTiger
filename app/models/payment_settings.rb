# == Schema Information
#
# Table name: payment_settings
#
#  id                               :integer          not null, primary key
#  active                           :boolean          not null
#  community_id                     :integer          not null
#  payment_gateway                  :string(64)
#  payment_process                  :string(64)
#  commission_from_seller           :integer
#  minimum_price_cents              :integer
#  minimum_price_currency           :string(3)
#  minimum_transaction_fee_cents    :integer
#  minimum_transaction_fee_currency :string(3)
#  confirmation_after_days          :integer          not null
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#  api_client_id                    :string(255)
#  api_private_key                  :string(255)
#  api_publishable_key              :string(255)
#  api_verified                     :boolean
#  api_visible_private_key          :string(255)
#  api_country                      :string(255)
#  key_encryption_padding           :boolean          default(FALSE)
#
# Indexes
#
#  index_payment_settings_on_community_id  (community_id)
#

class PaymentSettings < ApplicationRecord
  validates_presence_of(:community_id)
  scope :preauthorize, -> { where(payment_process: :preauthorize) }
  scope :paypal, -> { preauthorize.where(payment_gateway: :paypal) }
  scope :stripe, -> { preauthorize.where(payment_gateway: :stripe) }


  def self.create_paypal_accounts
    paypal_comm_ids = PaymentSettings.where(:payment_gateway => "paypal").pluck(:community_id)
    PaymentSettings.where(:payment_gateway => "stripe").where.not(:community_id => paypal_comm_ids).each do |pa|
      comm_currency = Community.find_by_id(pa.community_id).try(:currency)
      minimum_transaction_fee_currency1 = pa.minimum_transaction_fee_currency.presence || comm_currency
      minimum_price_currency1 = pa.minimum_price_currency
      minimum_price_cents1 = pa.minimum_price_cents
      create(community_id: pa.community_id, active: true, confirmation_after_days: 14, payment_gateway: "paypal", minimum_transaction_fee_cents: 0, minimum_transaction_fee_currency: minimum_transaction_fee_currency1, minimum_price_cents: minimum_price_cents1, minimum_price_currency: minimum_price_currency1, payment_process: "preauthorize", commission_from_seller: 0)
    end
  end


end
