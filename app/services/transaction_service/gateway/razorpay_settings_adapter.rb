module TransactionService::Gateway
    class RazorpaySettingsAdapter < SettingsAdapter
  
      PaymentSettingsStore = TransactionService::Store::PaymentSettings
  
      def configured?(community_id:, author_id:)
        payment_settings = Maybe(PaymentSettingsStore.get_active_by_gateway(community_id: community_id, payment_gateway: :razorpay))
                           .select {|set| razorpay_settings_configured?(set)}
  
        personal_account_verified = razorpay_account_created?(community_id: community_id, person_id: author_id, settings: payment_settings)
        payment_settings_available = payment_settings.map {|_| true }.or_else(false)
  
        [personal_account_verified, payment_settings_available].all?

        #payment_settings_available
      end
  
      def tx_process_settings(opts_tx)
        currency = opts_tx[:unit_price].currency
        p_set = PaymentSettingsStore.get_active_by_gateway(community_id: opts_tx[:community_id], payment_gateway: :razorpay)
  
        {minimum_commission: Money.new(p_set[:minimum_transaction_fee_cents], currency),
         commission_from_seller: p_set[:commission_from_seller],
         automatic_confirmation_after_days: p_set[:confirmation_after_days]}
      end
  
      private
  
      def razorpay_settings_configured?(settings)
        settings[:payment_gateway] == :razorpay && settings[:api_verified] && !!settings[:commission_from_seller] && !!settings[:minimum_price_cents]
      end
  
      def razorpay_account_created?(community_id:, person_id: nil, settings: Maybe(nil))
        account = RazorpayService::API::Api.accounts.get(person_id: person_id, community_id: community_id).data
        account && account[:razorpay_account_id].present? 
      end
  
    end
  end
  