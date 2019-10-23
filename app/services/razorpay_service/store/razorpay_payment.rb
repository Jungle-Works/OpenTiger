module RazorpayService::Store::RazorpayPayment

    RazorpayPaymentModel = ::RazorpayPayment

    InitialPaymentData = EntityUtils.define_builder(
        [:payment_id, :mandatory, :string],
        [:order_id, :mandatory, :string],
        [:payer, :mandatory, :string],
        [:merchant, :mandatory, :string],
        [:transaction_id, :mandatory, :fixnum],
        [:currency, :mandatory, :string],
        [:order_total_cents, :fixnum],
        [:fee_total_cents, :fixnum],
        [:payement_status, :string]
      )

  
    RazorpayPayment = EntityUtils.define_builder(
      [:payment_id, :mandatory, :string],
      [:order_id, :mandatory, :string],
      [:payer, :mandatory, :string],
      [:merchant, :mandatory, :string],
      [:transaction_id, :mandatory, :fixnum],
      [:currency, :string],
      [:sum, :money],
      [:fee, :money],
      [:commission, :money],
      [:payment_status, :mandatory, :to_symbol]
    )

    module_function
  
    def update(opts)
      if(opts[:data].nil?)
        raise ArgumentError.new("No data provided")
      end
  
      payment = find_payment(opts)
      old_data = from_model(payment)
      update_payment!(payment, opts[:data])
    end
  
    def create(transaction_id, order)
      payment_data = InitialPaymentData.call(order.merge({community_id: community_id, transaction_id: transaction_id}))
      model = RazorpayPaymentModel.create!(payment_data)
      from_model(model)
    end
  
    def get(transaction_id)
    puts " the payment found is : " , RazorpayPaymentModel.where(
        transaction_id: transaction_id
        ).first
      Maybe(RazorpayPaymentModel.where(
          transaction_id: transaction_id
          ).first)
        .map { |model| from_model(model) }
        .or_else(nil)
    end
  
    def from_model(razorpay_payment)
        puts " the razorpay payement model received is : ", razorpay_payment
      hash = HashUtils.compact(
        EntityUtils.model_to_hash(razorpay_payment).merge({
            sum: Money.new(razorpay_payment.order_total_cents, razorpay_payment.currency ),
            commission: Money.new(razorpay_payment.fee_total_cents, razorpay_payment.currency )
          }))
      RazorpayPayment.call(hash)
    end
  
    def find_payment(opts)
      StripePaymentModel.where(
        "(community_id = ? and transaction_id = ?)",
        opts[:community_id],
        opts[:transaction_id]
      ).first
    end
  
    def data_changed?(old_data, new_data)
      old_data != new_data
    end
  
    def update_payment!(payment, data)
      payment.update_attributes!(data)
      from_model(payment.reload)
    end
  end
  