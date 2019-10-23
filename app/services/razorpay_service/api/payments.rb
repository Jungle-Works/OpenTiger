module RazorpayService::API
    class Payments
      class << self       
        # PaymentStore = StripeService::Store::StripePayment we will get Razorpay Payment here
        PaymentStore = RazorpayService::Store::RazorpayPayment
        TransactionStore = TransactionService::Store::Transaction
        #this creates a razorpay payment details  
        def create_preauth_payment(tx, gateway_fields)
        payment = RazorpayPayment.create(:payment_id => gateway_fields[:razorpay_payment_id], :order_id => gateway_fields[:razorpay_order_id], :payer => tx.buyer.id, :merchant => tx.seller.id, :transaction_id => tx.id, :currency => tx.community.currency, :order_total_cents => order_total(tx).cents, :fee_total_cents => order_commission(tx).cents, :payment_status => "authorized")
        Result::Success.new(payment)
        rescue => exception
          Result::Error.new(exception.message)
        end
        #this cancels a preauth transaction
        def cancel_preauth(tx, reason)
          payment = {}
          Result::Success.new(payment)
        rescue => e
          Result::Error.new(e.message)
        end

        def cancel_preauth(tx) 
          RazorpayPayment.find_by(transaction_id: tx.id).update_attribute(:payment_status, "rejected")
          payment = {}
          Result::Success.new(payment)
          rescue => exception
            Result::Error.new(exception.message)
        end  

        #this function transfers the payment  

        def transfer(tx)
          pay_id = get_payment_id(tx.id)
          puts " the transaction will be transferred here ... for payment id : " , get_payment_id(tx.id) , " the listing author is : " ,  tx.listing_author_id
          seller_account = razorpay_accounts_api.get(person_id: tx.listing_author_id, community_id: tx.community_id).data
          if seller_account && seller_account[:verification_status] == "activated"
          razorpay_api.direct_transfer(community: tx.community_id, payment_id: pay_id, amount: order_total(tx).cents - order_commission(tx).cents, razorpay_account_id: seller_account[:razorpay_account_id])
          else  
          raise "The Seller Account is not verified"
          end  
          payment = {}
          Result::Success.new(payment)
          rescue => exception
          Result::Error.new(exception.message)
        end  
        #this actually captures the payement
  
        def capture(tx)
        pay_id = get_payment_id(tx.id)
        if !pay_id.nil?
        result =  razorpay_api.payment_capture(community: tx.community_id, payment_id: pay_id, amount: order_total(tx).cents)
        RazorpayPayment.find_by(payment_id: pay_id).update_attribute(:payment_status, "captured") 
        else  
        raise "Payment id not found"
        end  
        payment = {}     
          Result::Success.new(payment)
        rescue => exception    
          Result::Error.new(exception.message)
        end
  
        def payment_details(tx)
        payment = PaymentStore.get(tx.id)
        puts " the payment store says .. .  " , payment
        unless payment
          total      = order_total(tx)
          commission = order_commission(tx)
          fee        = Money.new(0, total.currency)
          payment = {
            sum: total,
            commission: commission,
            real_fee: fee,
            subtotal: total - fee,
          }   
        gateway_fee = Money.new(0 , payment[:currency] )
        end
      ret =   {
            payment_total:       payment[:sum] || payment[:total_price_cents],
            total_price:         payment[:sum] || payment[:total_price_cents],
            charged_commission:  payment[:commission] || payment[:fee_total_cents],
            payment_gateway_fee: gateway_fee
         }


         puts " the return value is : . ... . .. . . " , ret


         ret   
    end

        def razorpay_accounts_api 
          RazorpayService::API::Api.accounts
        end  

  
        def razorpay_api
            RazorpayService::API::Api.wrapper
        end
        def order_total(tx)
          shipping_total = Maybe(tx.shipping_price).or_else(0)
          additional_price = Maybe(Money.new(tx.checkout_field_price_cents,tx.community.currency)).or_else(0)
          tx.unit_price * tx.listing_quantity + shipping_total + additional_price
        end
  
        def order_commission(tx)
          commision = (tx.unit_price * tx.listing_quantity) + Maybe(Money.new(tx.checkout_field_price_cents,tx.community.currency)).or_else(0)
          TransactionService::Transaction.calculate_commission(commision, tx.commission_from_seller, tx.minimum_commission)
        end

        def get_payment_id(tx_id)
            payment_record = RazorpayPayment.find_by(transaction_id: tx_id)
            if payment_record.present?  
                return payment_record.payment_id  
            end   
            nil 
        end  

        def getAmountInPaise(money_str) 
            int_part_str, fract_part_str = money_str.sub(",", ".").split(".") 
            int_part = int_part_str.to_i || 0 
            fract_part = fract_part_str.to_i || 0 
            ( int_part * 100 ) + fract_part 
        end
  
      end
    end
  end
  