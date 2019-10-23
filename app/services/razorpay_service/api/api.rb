module RazorpayService
    module API
      class Api
        def self.accounts
          @accounts ||= RazorpayService::API::Accounts.new
        end
  
        def self.wrapper
          RazorpayService::API::RazorpayApiWrapper
        end
  
        def self.payments
           RazorpayService::API::Payments
        end
      end
    end
  end