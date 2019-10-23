module TransactionService::Gateway
    class RazorpayAdapter < GatewayAdapter
  
      def implements_process(process)
        [:preauthorize].include?(process)
      end
  
      def create_payment(tx:, gateway_fields:, force_sync:)
       result =  razorpay_api.payments.create_preauth_payment(tx, gateway_fields)
       puts " the tx is : " , tx , " the gateway fields are : " , gateway_fields
        puts " Sakshi 22"
        payment = { "success" => true }
        result = Result::Success.new(payment)
        SyncCompletion.new(result)
      end
  
      def reject_payment(tx:, reason: "")
        result = razorpay_payments.cancel_preauth(tx)
        SyncCompletion.new(result)
      end
  
      def complete_preauthorization(tx:)
        result =  razorpay_api.payments.capture(tx)
        SyncCompletion.new(result)
      end
  
      def get_payment_details(tx:)
        #stripe_api.payments.payment_details(tx)
        txdd = razorpay_api.payments.payment_details(tx)

        puts " inside payment adapter .. . " , txdd


        txdd  


      end
  
      private

      def razorpay_payments 
        RazorpayService::API::Api.payments
      end  

      def razorpay_api  
        RazorpayService::API::Api
      end 
    end
  end
  