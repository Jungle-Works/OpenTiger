class RazorpayService::API::RazorpayApiWrapper
  class << self

    # rubocop:disable ClassVars
    @@mutex ||= Mutex.new

    def order_create(community:, amount:)   
      with_razorpay_payement_config(community) do |payment_settings|
        begin  
        puts " the amout is : order_create" , amount
        puts "the payment settings is :  " , payment_settings
        order = Razorpay::Order.create amount: amount, currency: 'INR'
        {code: 200, message: "success", data: order , key_id: payment_settings.api_publishable_key, amount: amount} 
        rescue => e   
          {code: 400, message: e.message, data: {}, key_id: nil, amount: amount}
        end  
      end
    end  

    def verify_signature(community:, payment_response:)
      with_razorpay_payement_config(community) do  |payment_settings|
        begin    
          Razorpay::Utility.verify_payment_signature(payment_response)
          return true 
        rescue SecurityError => e
          return false
        end  
      end   
    end  

    def get_seller_account(account_id:, community:)
      begin 
        settings = payment_settings_for(community)
        key_id = settings.api_publishable_key
        api_secret = TransactionService::Store::PaymentSettings.decrypt_value(settings.api_private_key, settings.key_encryption_padding)
        uri = "https://api.razorpay.com/v1/beta/accounts/" + account_id
        uri = URI(uri)
        https = Net::HTTP.new(uri.host, uri.port)
        https.use_ssl = true
        req = Net::HTTP::Get.new(uri.path, {'Content-Type' =>'application/json'})
        req.basic_auth(key_id, api_secret)
        res = https.request(req)
        res = JSON.parse(res.body)
        puts " the response was : " , res
        if res["activation_details"].present?
        return res
        else   
        return "Error"
        end   
      rescue => exception 
        puts " the exception was : " ,  exception
        return "Error"
      end  
    end  

    def add_seller_account(data:, community:, person:)
      begin 
      settings = payment_settings_for(community)
      key_id = settings.api_publishable_key
      api_secret = TransactionService::Store::PaymentSettings.decrypt_value(settings.api_private_key, settings.key_encryption_padding)
      uri = "https://api.razorpay.com/v1/beta/accounts"
      uri = URI(uri)
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true
      req = Net::HTTP::Post.new(uri.path, {'Content-Type' =>'application/json'})
      req.basic_auth(key_id, api_secret)
      req.body = { 
        :name => data[:name],
        :email => data[:email],
        :tnc_accepted => data[:accept_rp_tnc] == "true" ? true : false,
        :account_details => {
           :business_name => data[:business_name],
           :business_type => data[:business_type]
        },
        :bank_account => 
        {
           "ifsc_code" => data[:ifsc_code],
           "beneficiary_name" => data[:beneficiary_name],
           "account_type" => data[:account_type],
           "account_number" => data[:account_number]
        }
      }
      req.body = req.body.to_json
      res = https.request(req)
      res = JSON.parse(res.body)
      RazorpayApiLog.create(:payment_id =>  person, :action => "seller account add", :api_response => res)
      if res["error"]
        raise res["error"]["description"]
      end   
      return {:status => res["activation_details"]["status"], :account_id => res["id"], :message => "success"}
      rescue => e  
      return { :status => "under_review" , :account_id => "nil" , :message => e }
      end 
      
    end  

    def get_account_verification_status  

    end  

    def payment_capture(community:, payment_id:, amount:)
      puts " inside payment capture of razorpay wrapper api ... " , payment_id
      with_razorpay_payement_config(community) do |payment_settings| 
        begin   
          puts "insside the begin .... "
          puts "the amont is .... :  ", amount
          payment = Razorpay::Payment.fetch(payment_id).capture({amount:amount})
          if payment.status == 'captured'
          return true
          end
          return false 
        rescue StandardError => e
          puts " the exception is : " , e  
          return false  
        end  
      end 
    end  

    def direct_transfer(community:, payment_id:, amount:, razorpay_account_id:)
    begin  
    puts " direct transfer using routes ... "
    settings = payment_settings_for(community)
    key_id = settings.api_publishable_key
    api_secret = TransactionService::Store::PaymentSettings.decrypt_value(settings.api_private_key, settings.key_encryption_padding)
    puts " the public key is : " , key_id
    puts " the secret key is : " , api_secret
    uri = "https://api.razorpay.com/v1/payments/" + payment_id + "/transfers"
    uri = URI(uri)
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    req = Net::HTTP::Post.new(uri.path, {'Content-Type' =>'application/json'})
    req.basic_auth(key_id, api_secret)
    req.body = { 
    :transfers => [
       {
        :account => razorpay_account_id,
        :amount => amount,
        :currency => "INR"
       }
    ]
    }
    req.body = req.body.to_json
    puts " the request body for fugu will be : " ,req.body
    res = https.request(req)
    res = JSON.parse(res.body)
    RazorpayApiLog.create(:payment_id =>  payment_id , :action => "transfer", :api_response => res)
    puts " the response was : " , res
    rescue => e   
      puts " there was an exception : " , e
      RazorpayApiLog.create(:payment_id =>  payment_id , :action => "transfer", :api_response => e)
    end   
    end 
    def payment_settings_for(community)
      PaymentSettings.where(community_id: community, payment_gateway: :razorpay, payment_process: :preauthorize).first
    end


    def configure_payment_for(settings)
      key_id = settings.api_publishable_key
      api_secret = TransactionService::Store::PaymentSettings.decrypt_value(settings.api_private_key, settings.key_encryption_padding)
      Razorpay.setup(key_id, api_secret) 
    end

    def configure_payment_for_api(settings)
      key_id = settings.api_publishable_key
      api_secret = TransactionService::Store::PaymentSettings.decrypt_value(settings.api_private_key, settings.key_encryption_padding)
    end   

    def reset_configurations
      #setting to expired keys
      Razorpay.setup('rzp_test_EdzVS4RfuaO2M2','pRgjT6C3WPKnED2sCYfDEcL6')
    end

    # This method should be used for all actions that require setting correct
    # Merchant details for the Razorpay gem

    def with_razorpay_payement_config(community, &block)
      @@mutex.synchronize {
        payment_settings = payment_settings_for(community)
        configure_payment_for(payment_settings)
        return_value = block.call(payment_settings)
        reset_configurations
        return return_value    
      }
    end   


    def with_razorpay_payement_config_api(community, &block)
      @@mutex.synchronize {
        payment_settings = payment_settings(community)
        configure_payment_for_api(payment_settings)
        return_value = block.call(payment_settings)
        reset_configurations
        return return_value    
      }
    end 
    
  end
end
