module RazorpayService::Store::RazorpayAccount
    RazorpayAccountModel = ::RazorpayAccount
  
    # only for country india and inr currency
    ALL_STRIPE_COUNTRIES = ["IN"]
    COUNTRIES = ALL_STRIPE_COUNTRIES & ::TransactionService::AvailableCurrencies::COUNTRY_SET_RAZORPAY

  
    VALID_BANK_CURRENCIES = ["INR"]
  
    RazorpayAccountCreate = EntityUtils.define_builder(
      [:community_id, :mandatory, :fixnum],
      [:person_id, :optional, :string],
      [:verification_status, :mandatory, :string],
      [:razorpay_account_id, :string, :mandatory]
    )
  
    RazorpayAccount = EntityUtils.define_builder(
      [:community_id, :fixnum],
      [:person_id, :string],
      [:verification_status, :string],
      [:razorpay_account_id, :string]
    )
  
    module_function
  
    def create(opts:)
      entity = RazorpayAccountCreate.call(opts)
      account_model = RazorpayAccountModel.where(community_id: entity[:community_id], person_id: entity[:person_id]).first
      if account_model
        account_model.update_attributes(entity)
      else
        account_model = RazorpayAccountModel.create!(entity)
      end
      account_model
    end
  
    def create_customer(opts:)
      account_model = RazorpayAccount.create!(opts)
      from_model(account_model)
    end
  
    # def update_bank_account(community_id:, person_id:, opts:)
    #   find_params = {
    #     community_id: community_id,
    #     person_id: person_id,
    #   }
    #   model = StripeAccountModel.where(find_params).first
    #   entity = StripeBankAccount.call(opts)
    #   model.update_attributes(entity)
    #   from_model(model)
    # end
  
    def update_field(community_id:, person_id:, field:, value:)
      find_params = {
        community_id: community_id,
        person_id: person_id,
      }
      model = RazorpayAccountModel.where(find_params).first
      model.update(field => value)
      from_model(model)
    end
  
    def get(person_id: nil, community_id:)
       ret = RazorpayAccountModel.where(
          person_id: person_id,
          community_id: community_id
       ).first

      puts " the return value is : " , ret
      ret
    end
  
    def get_active_users(community_id:)
        RazorpayAccountModel.where(
          community_id: community_id
        )
          .where.not(person_id: nil)
          .map(&:person_id)
    end
  
    def from_model(model)
      Maybe(model)
        .map { |m| EntityUtils.model_to_hash(m) }
        .map { |hash| RazorpayAccountModel.call(hash) }
        .or_else(nil)
    end
  
    def destroy(person_id: nil, community_id:)
      RazorpayAccountModel.where(
        person_id: person_id,
        community_id: community_id
      ).destroy_all
    end
  end
  