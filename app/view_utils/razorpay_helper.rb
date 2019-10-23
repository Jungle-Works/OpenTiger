module RazorpayHelper

  TxApi = TransactionService::API::Api

  module_function

  # Check that we have an active provisioned :razorpay payment gateway
  # for the community AND that the community admin has fully
  # configured the gateway.
  def community_ready_for_payments?(community_id)
    razorpay_active?(community_id) &&
    Maybe(TxApi.settings.get(community_id: community_id, payment_gateway: :razorpay, payment_process: :preauthorize))
    .map {|res| res[:success] ? res[:data] : nil}
    .select {|set| set[:commission_from_seller] && set[:minimum_price_cents]}
    .map {|_| true}
    .or_else(false)
  end

  # Check that both the community is fully configured with an active
  # :razorpay payment gateway and that the given user has connected his
  # razorpay account.
  def user_and_community_ready_for_payments?(person_id, community_id)
    razorpay_active?(community_id) && user_razorpay_active?(person_id , community_id)
  end

  def user_razorpay_active?(person_id , community_id)
    account = RazorpayService::API::Api.accounts.get(person_id: person_id, community_id: community_id).data
    account && account[:razorpay_account_id].present?
  end

  # Check that the user has connected his paypal account for the
  # community

  def razorpay_available?(community)
    #stripe_mode = StripeService::API::Api.wrapper.charges_mode(community.id)
    TransactionService::AvailableCurrencies.razorpay_allows_country_and_currency?(
      community.country,
      community.currency
    )
  end

  def account_prepared_for_community?(community_id)
    account_prepared?(community_id: community_id)
  end

  # Private
  def account_prepared?(community_id:, person_id: nil, settings: Maybe(nil))
    #acc_state = accounts_api.get(community_id: community_id, person_id: person_id).maybe()[:state].or_else(:not_connected)
    acc_state = :verified
    commission_type = settings[:commission_type].or_else(nil)

    acc_state == :verified || (acc_state == :connected)
  end
  private_class_method :account_prepared?

  # Check that the currently active payment gateway (there can be only
  # one active at any time) for the community is :paypal. This doesn't
  # check that the gateway is fully configured. Use
  # community_ready_for_payments? if that's what you need.
  def razorpay_active?(community_id)
    settings = Maybe(TxApi.settings.get(community_id: community_id, payment_gateway: :razorpay, payment_process: :preauthorize))
    .select { |result| result[:success] }
    .map { |result| result[:data] }
    .or_else(false)

  return settings && settings[:active] && settings[:api_verified]
  end


  # Check if Razorpay has been provisioned for a community.
  #
  # This is different from Razorpay being active. Provisioned just means
  # that admin can configure and activate Razorpay.
  def razorpay_provisioned?(community_id)
    settings = Maybe(TxApi.settings.get(
                      community_id: community_id,
                      payment_gateway: :razorpay,
                      payment_process: :preauthorize))
      .select { |result| result[:success] }
      .map { |result| result[:data] }
      .or_else(nil)

    return !!settings
  end

  # # Check if the user has open listings in the community but has not
  # # finished connecting his paypal account.
  def open_listings_with_missing_payment_info?(user_id, community_id)
    razorpay_active?(community_id) &&
    !user_and_community_ready_for_payments?(user_id, community_id) &&
    PaymentHelper.open_listings_with_payment_process?(community_id, user_id)
  end

  def business_type_translation(type)
    tranlation_map = {
      "llp" => "razorpay.seller_account.llp",
      "ngo" => "razorpay.seller_account.ngo",
      "other" => "razorpay.seller_account.other",
      "individual" => "razorpay.seller_account.individual",
      "partnership" => "razorpay.seller_account.partnership",
      "proprietorship" => "razorpay.seller_account.proprietorship",
      "public_limited" => "razorpay.seller_account.public_limited",
      "private_limited" => "razorpay.seller_account.private_limited",
      "trust" => "razorpay.seller_account.trust",
      "society" => "razorpay.seller_account.society",
      "not_yet_registered" => "razorpay.seller_account.not_yet_registered",
      "educational_institutes" => "razorpay.seller_account.educational_institutes"
    }

    I18n.t(tranlation_map[type])
  end

  def business_type_options(options)
    options.collect { |option| [business_type_translation(option), option] }.insert(0, [I18n.t("razorpay.seller_account.select_one"), nil])
  end

end
