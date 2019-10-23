module RazorpayService::API

    class Accounts
      def get(community_id:, person_id: nil)
        Result::Success.new(razorpay_accounts_store.get(person_id: person_id, community_id: community_id))
      end
  
      def get_active_users(community_id:)
        razorpay_accounts_store.get_active_users(community_id: community_id)
      end
  
      def create(params:, community:, person:)
        # metadata = {yelo_community_id: community_id, yelo_person_id: person_id, yelo_mode: stripe_api.charges_mode(community_id)}
        # result = stripe_api.register_seller(community: community_id, account_info: body, metadata: metadata)
        # data = body.merge(stripe_seller_id: result.id, community_id: community_id, person_id: person_id)
        data = params  
        stat = razorpay_api.add_seller_account(data: data, community: community, person: person)
        data = {
          :person_id => person,
          :community_id => community,
          :razorpay_account_id => stat[:account_id],
          :verification_status => stat[:status]
        }
        if stat[:account_id] != "nil"
          Result::Success.new(razorpay_accounts_store.create(opts: data))
        else  
          if stat[:message].present? 
          raise "#{stat[:message]}"
          else  
          raise "Unknown Error !!"
          end
        end
      rescue => e 
        allow_razorpay_exceptions(e)
      end
  
    # the below function in future will register merchant api   
    #   def create_bank_account(community_id:, person_id:, body:)
    #     account = stripe_accounts_store.get(person_id: person_id, community_id: community_id).to_hash
    #     result = stripe_api.create_bank_account(community: community_id, account_info: account.merge(body))
    #     data = body.merge(stripe_bank_id: result.id)
    #     Result::Success.new(stripe_accounts_store.update_bank_account(community_id: community_id, person_id: person_id, opts: data))
    #   rescue => e
    #     allow_stripe_exceptions(e)
    #   end
  
      def create_customer(community_id:, person_id:, body:)
        data = { community_id: community_id, person_id: person_id}
        Result::Success.new(razorpay_accounts_store.create_customer(opts: data))
      rescue => e
        allow_razorpay_exceptions(e)
      end
  
    #   def update_account(community_id:, person_id:, attrs:)
    #     account = stripe_accounts_store.get(person_id: person_id, community_id: community_id).to_hash
    #     stripe_api.update_account(community: community_id, account_id: account[:stripe_seller_id], attrs: attrs)
    #     Result::Success.new(account)
    #   rescue => e
    #     allow_stripe_exceptions(e)
    #   end
  
      def update_field(community_id:, person_id:, field:, value:)
        Result::Success.new(razorpay_accounts_store.update_field(community_id: community_id, person_id: person_id, field: field, value: value))
      rescue => e
        allow_razorpay_exceptions(e)
      end
  
    #   def send_verification(community_id:, person_id:, personal_id_number:, file:)
    #     account = stripe_accounts_store.get(community_id: community_id, person_id: person_id)
    #     stripe_api.send_verification(community: community_id, account_id: account[:stripe_seller_id], personal_id_number: personal_id_number, file_path: file)
    #     Result::Success.new(account)
    #   rescue => e
    #     allow_stripe_exceptions(e)
    #   end
  
      def destroy(community_id:, person_id:)
        Result::Success.new(razorpay_accounts_store.destroy(community_id: community_id, person_id: person_id))
      rescue => e
        allow_razorpay_exceptions(e)
      end
  
    #   def delete_seller_account(community_id:, person_id: nil)
    #     account = stripe_accounts_store.get(person_id: person_id, community_id: community_id)
    #     if account && account[:stripe_seller_id].present?
    #       res = Result::Success.new(stripe_api.delete_account(community: community_id, account_id: account[:stripe_seller_id]))
    #       stripe_accounts_store.destroy(person_id: person_id, community_id: community_id)
    #       res
    #     else
    #       Result::Success.new()
    #     end
    #   rescue => e
    #     allow_razorpay_exceptions(e)
    #   end
  
      private
  
      def razorpay_api
        RazorpayService::API::Api.wrapper
      end
  
      def razorpay_accounts_store
        RazorpayService::Store::RazorpayAccount
      end
  
      def allow_razorpay_exceptions(e)
        if e.class.name =~ /^Razorpay/ || e.message =~ /^Razorpay/
          Result::Error.new(e)
        else
          Result::Error.new(e)
        end
      end
    end
  end
  