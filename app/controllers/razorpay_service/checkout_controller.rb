class RazorpayService::CheckoutController < ApplicationController

  layout "app_pages_layout"
  
    def order_create  
        amount = getAmountInPaise(params[:price]) 
        order = razorapay_api.order_create(community: @current_community.id,amount: amount)
        puts " the order is : " , order
        @order_record = RazorpayOrder.create(:razorpay_order_id => order[:data].id, :community_id => @current_community.id, :currency => "INR", :amount => order[:amount])
        hsh = {}
        if order[:code] == 200  
          hsh[:status] = 200 
          hsh[:message] = "success"
          hsh[:order_id] = @order_record.id 
        else  
          hsh[:status] = 201
          hsh[:message] = order[:message]
          hsh[:order_id] = nil 
        end    
        render :json => hsh.to_json
    end   

    def verify  
      payment_response = {
        :razorpay_order_id => params["razorpay_order_id"],
        :razorpay_payment_id => params["razorpay_payment_id"],
        :razorpay_signature => params["razorpay_signature"]
       }
      res = razorapay_api.verify_signature(community: @current_community.id, payment_response: payment_response)
      res_code = 200
      message = "success"
      if res == false
        res_code = 400    
        message = "verification failed"
      end   
      @response = { 
        "status" => res_code, 
        "message" => message
        } 
      render :json => @response.to_json
    end  

    def success 
      return redirect_to error_not_found_path if params[:order_id].blank?

    end  

    def cancel  
      return redirect_to person_listing_path(person_id: @current_user.id, id: params[:listing_id])
    end  

    def payout

    end 

    def redirect
      puts "orderrr : " , params["id"]
      @order_detail = RazorpayOrder.find_by(id: params["id"])
      puts " key id haiii " , razorpay_tx_settings[:api_publishable_key]
      render partial:"razorpay_service/redirect", locals: {
                              order_id:  @order_detail[:razorpay_order_id],
                              amount: @order_detail[:amount],
                              name: @current_user.name_or_username,
                              organisation: @current_community.ident,
                              redirect_url: redirect_razorpay_service_checkout_index_path,
                              cancel_url: cancel_razorpay_service_checkout_index_path,
                              key_id: razorpay_tx_settings[:api_publishable_key]  
                            }
    end 

    private  

    def getAmountInPaise(money_str) 
      int_part_str, fract_part_str = money_str.sub(",", ".").split(".") 
      int_part = int_part_str.to_i || 0 
      fract_part = fract_part_str.to_i || 0 
      ( int_part * 100 ) + fract_part 
    end

    def razorpay_tx_settings 
      Maybe(TransactionService::API::Api.settings.get(community_id: @current_community.id, payment_gateway: :razorpay, payment_process: :preauthorize)) 
      .select { |result| result[:success] } 
      .map { |result| result[:data] } 
      .or_else({}) 
    end

    def razorapay_api 
        RazorpayService::API::Api.wrapper
    end  
end
