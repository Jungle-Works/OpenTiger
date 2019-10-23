class AppPagesController < ApplicationController

    layout "app_pages_layout"
    
    def transaction
      @request_data = OrderRequestDetail.find_by_id(params[:order_request_id])
      @order_request_data = JSON.parse(@request_data.try(:order_detail))
      @current_user = @current_community.tb_active_app_sessions.find_by_session_token(params[:app_session_token]).try(:person)
    end

    def create_order_id 
      order = razorapay_api.order_create(community: @current_community.id,amount: 5000)
      puts order 
      hsh = {}
      if order[:code] == 200  
        hsh[:status] = 200 
        hsh[:message] = "success"
        hsh[:order_id] = order[:data].id
        hsh[:redirect_url] = "https://kanslkdlsakdlknlklknlkasndlknlknlkn"
      else  
        hsh[:status] = 404 
        hsh[:message] = order[:message]
        hsh[:order_id] = nil 
        hsh[:redirect_url] = nil
      end    
      render :json => hsh.to_json
    end

    def create_transactions
        begin
            # tx_params[:start_on] = "2019-07-27"
            # tx_params[:end_on] = "2019-07-28"
            # tx_params[:listing_id] = 118
            # tx_params[:per_hour] = 0
            # tx_params[:start_time] = "10:11"
            # tx_params[:end_time] = "11:11"
            # tx_params[:payment_type] = "stripe"
          @current_user = @current_community.people.find(params[:person_id])
          listing = @current_community.listings.find_by_id(params[:listing_id])
          @listing = listing
          params[:delivery] = nil unless params[:delivery].present?
          params[:quantity] = nil unless params[:quantity].present?
          params_validator = params_per_hour? ? TransactionService::Validation::NewPerHourTransactionParams : TransactionService::Validation::NewTransactionParams
          @request_data = OrderRequestDetail.find_by_id(params[:order_request_id])
          @order_request_data = JSON.parse(@request_data.try(:order_detail))
          validation_result = params_validator.validate(params).and_then { |params_entity|
            tx_params = add_defaults(
              params: params_entity,
              shipping_enabled: listing.require_shipping_address,
              pickup_enabled: listing.pickup_enabled)
      
            TransactionService::Validation::Validator.validate_initiated_params(
              tx_params: tx_params,
              marketplace_uuid: @current_community.uuid_object,
              listing: listing,
              quantity_selector: listing.quantity_selector&.to_sym,
              shipping_enabled: listing.require_shipping_address,
              availability_enabled: listing.availability.to_sym == :booking,
              pickup_enabled: listing.pickup_enabled,
              transaction_agreement_in_use: @current_community.transaction_agreement_in_use?,
              stripe_in_use: StripeHelper.user_and_community_ready_for_payments?(listing.author_id, @current_community.id))
          }
 
          if validation_result.success
            initiated_success(validation_result.data)
          else
            initiated_error(validation_result.data)
          end
      





            # tx_params =  params


            # @current_user = @current_community.people.find(params[:person_id])
            # listing = @current_community.listings.find_by_id(params[:listing_id])
            # is_booking = is_booking?(listing)
            # quantity = calculate_quantity(tx_params: tx_params, is_booking: is_booking, unit: listing.unit_type)
            # shipping_total = calculate_shipping_from_listing(tx_params: tx_params, listing: listing, quantity: quantity)
            # exp_date = params[:expiration_date].split('-')
            # Stripe.api_key = PaymentSettings.where(community_id: @current_community, payment_gateway: :stripe, payment_process: :preauthorize).first.api_publishable_key
            # stoken = Stripe::Token.create(:card => {:number => params[:card_number], :exp_month => exp_date[1], :exp_year => exp_date[0], :cvc => params[:cardCode]})
            #     tx_response = create_preauth_transaction(
            #   payment_type: params[:payment_type].to_sym,
            #   community: @current_community,
            #   listing: listing,
            #   listing_quantity: quantity,
            #   user: @current_user,
            #   content: tx_params[:message],
            #   force_sync: !request.xhr?,
            #   delivery_method: tx_params[:delivery],
            #   shipping_price: shipping_total.total,
            #   booking_fields: {
            #     start_on:   tx_params[:start_on],
            #     end_on:     tx_params[:end_on],
            #     start_time: tx_params[:start_time],
            #     end_time:   tx_params[:end_time],
            #     per_hour:   tx_params[:per_hour]
            #   },
            #   stoken: stoken
            #   )
            #   handle_tx_response(tx_response, params[:payment_type].to_sym)
        rescue Exception => e
          hsh = {}
          hsh[:status] = 400
          hsh[:message] = e.message
          hsh[:redirect_link] = payment_error_app_pages_path(:payment_callback => "error", :error => e.message.presence || "Error")
          render :json => hsh.to_json
        end
    end


    def payment_success
        
    end
    def payment_error
        
    end

    def terms
      @selected_tribe_navi_tab = "about"
      @selected_left_navi_link = "terms"
    end

    def privacy
      @selected_tribe_navi_tab = "about"
      @selected_left_navi_link = "privacy"
    end

  private

  def calculate_additional_checkout_price(data)
    additional_price = 0
    checkout_fields =  data
    if requiresJSONParse(checkout_fields)
      checkout_fields = JSON.parse(checkout_fields)
    end  
    begin
      additional_price = (checkout_fields.select { |cf| cf["field_type"] == "DropdownField"}.map{ |sf| sf["value"].map{ |sv| sv["value"].to_i }.sum }.sum ) * 100 
    rescue => exception 
    else 
    end 
    additional_price
  end


  def requiresJSONParse(unit) 
    begin 
      JSON.parse(unit) 
      return true 
    rescue => e 
      return false 
    end 
  end

  def initiated_success(tx_params)
    listing = @listing
    is_booking = is_booking?(listing)

    quantity = calculate_quantity(tx_params: tx_params, is_booking: is_booking, unit: listing.unit_type)
    shipping_total = calculate_shipping_from_listing(tx_params: tx_params, listing: listing, quantity: quantity)
    exp_date = params[:expiration_date].split('-')
    Stripe.api_key = PaymentSettings.where(community_id: @current_community, payment_gateway: :stripe, payment_process: :preauthorize).last.api_publishable_key
    stoken = Stripe::Token.create(:card => {:number => params[:card_number], :exp_month => exp_date[1], :exp_year => exp_date[0], :cvc => params[:cardCode]})
  
    tx_response = create_preauth_transaction(
      payment_type: params[:payment_type].to_sym,
      community: @current_community,
      listing: listing,
      listing_quantity: quantity,
      user: @current_user,
      content: tx_params[:message],
      force_sync: !request.xhr?,
      delivery_method: tx_params[:delivery],
      shipping_price: shipping_total.total,
      stoken: stoken.id,
      booking_fields: {
        start_on:   tx_params[:start_on],
        end_on:     tx_params[:end_on],
        start_time: tx_params[:start_time],
        end_time:   tx_params[:end_time],
        per_hour:   tx_params[:per_hour]
      })

    handle_tx_response(tx_response, params[:payment_type].to_sym)
  end

  def initiated_error(data)
    # error_msg, path =
      if data.is_a?(Array)
        # Entity validation failed
        # logger.error(msg, :transaction_initiated_error, data)
        error_msg = "invalid_parameters"
        # [t("listing_conversations.preauthorize.invalid_parameters"), listing_path(listing.id)]

      elsif [:dates_missing, :end_cant_be_before_start, :delivery_method_missing, :at_least_one_day_or_night_required].include?(data[:code])
        # logger.error(msg, :transaction_initiated_error, data)
        error_msg = "invalid_parameters"
        # [t("listing_conversations.preauthorize.invalid_parameters"), listing_path(listing.id)]
      elsif data[:code] == :agreement_missing
        # User error, no logging here
        error_msg = "required_error"

        # [t("error_messages.transaction_agreement.required_error"), error_path(data[:tx_params])]
      elsif data[:code] == :dates_not_available
        error_msg = "double_booking_payment_voided"
        # [t("error_messages.booking.double_booking_payment_voided"), listing_path(listing.id)]
      else
        error_msg = "No error handler for this."
        # raise NotImplementedError.new("No error handler for: #{msg}, #{data.inspect}")
      end
      hsh = {}
      hsh[:status] = 400
      hsh[:message] = error_msg
      hsh[:redirect_link] = payment_error_app_pages_path(:payment_callback => "error", :error => error_msg.presence || "Error")
      render :json => hsh.to_json
    # render_error_response(request.xhr?, error_msg, path)
  end


    def params_per_hour?
      params[:per_hour] == '1'
    end

    def calculate_shipping_from_listing(tx_params:, listing:, quantity:)
        if tx_params[:delivery] == :shipping
        TransactionService::Validation::ShippingTotal.new(
            initial: listing.shipping_price,
            additional: listing.shipping_price_additional,
            quantity: quantity)
        else
        TransactionService::Validation::NoShippingFee.new
        end
    end

    def is_booking?(listing)
        [ListingUnit::DAY, ListingUnit::NIGHT].include?(listing.quantity_selector) ||
        (listing.unit_type.to_s == ListingUnit::HOUR && listing.availability == 'booking')
    end

    def calculate_quantity(tx_params:, is_booking:, unit:)
        if is_booking
            if tx_params[:per_hour]
                DateUtils.duration_in_hours(tx_params[:start_time], tx_params[:end_time])
            else
                DateUtils.duration(tx_params[:start_on], tx_params[:end_on])
            end
        else
            tx_params[:quantity] || 1
        end
    end

    def create_preauth_transaction(opts)
        case opts[:payment_type].to_sym
        when :paypal
            # PayPal doesn't like images with cache buster in the URL
            logo_url = Maybe(opts[:community])
                    .wide_logo
                    .select { |wl| wl.present? }
                    .url(:paypal, timestamp: false)
                    .or_else(nil)

            gateway_fields =
            {
                merchant_brand_logo_url: logo_url,
                success_url: success_paypal_service_checkout_orders_url,
                cancel_url: cancel_paypal_service_checkout_orders_url(listing_id: opts[:listing].id)
            }
        when :stripe
            gateway_fields =
            {
                stripe_email: @current_user.primary_email.address,
                stripe_token: opts[:stoken],
                shipping_address: params[:shipping_address],
                service_name: @current_community.name_with_separator(I18n.locale)
            }
        end

        if (params["textTitle"])
            titleObject = [
            {
                :title => params[:textTitle],
                :value => params[:additional_text_field]
            }
            ].to_json
        end

        if (params["dropdownTitle"])
            titleObject = [
            {
                :title => params[:dropdownTitle],
                :value => params[:additionInfoDropdown].to_f
            }
            ].to_json
        end

        if (params["dropdownTitle"] && params["textTitle"])
            titleObject = [
            {
                :title => params[:textTitle],
                :value => params[:additional_text_field]
            },
            {
                :title => params[:dropdownTitle],
                :value => params[:additionInfoDropdown].to_f
            }
            ].to_json
        end

        if (!params["dropdownTitle"] && !params["textTitle"])
            titleObject = ''
        end
        p opts[:listing].price
        p params[:additionInfoDropdown].to_f
        p "vasuuuuuu"
        price = calculate_additional_checkout_price(@order_request_data["checkout_fields"])
        transaction = {
                community_id: opts[:community].id,
                community_uuid: opts[:community].uuid_object,
                listing_id: opts[:listing].id,
                listing_uuid: opts[:listing].uuid_object,
                listing_title: opts[:listing].title,
                starter_id: opts[:user].id,
                starter_uuid: opts[:user].uuid_object,
                listing_author_id: opts[:listing].author.id,
                listing_author_uuid: opts[:listing].author.uuid_object,
                listing_quantity: opts[:listing_quantity],
                unit_type: opts[:listing].unit_type,
                unit_price: opts[:listing].price,
                unit_tr_key: opts[:listing].unit_tr_key,
                unit_selector_tr_key: opts[:listing].unit_selector_tr_key,
                availability: opts[:listing].availability,
                content: opts[:content],
                payment_gateway: opts[:payment_type].to_sym,
                payment_process: :preauthorize,
                booking_fields: opts[:booking_fields],
                delivery_method: opts[:delivery_method] || :none,
                additional_info: titleObject,
                additional_price: params[:additionInfoDropdown].to_f,
                checkout_field_price_cents: price || 0
        }
        if(opts[:delivery_method] == :shipping)
            transaction[:shipping_price] = opts[:shipping_price]
        end
        TransactionService::Transaction.create({
            transaction: transaction,
            gateway_fields: gateway_fields
            },
            force_sync: opts[:payment_type] == :stripe || opts[:force_sync])
    end


    def handle_tx_response(tx_response, gateway)

      puts "vasuuu#{tx_response}"
        if !tx_response[:success]
          render_error_response(request.xhr?, t("error_messages.#{gateway}.generic_error"), action: :initiate)
        elsif (tx_response[:data][:gateway_fields][:redirect_url])
          xhr_json_redirect tx_response[:data][:gateway_fields][:redirect_url]
        elsif gateway == :stripe
          @deliveryData = {
            
            :lat => Maybe(params["delivery_lat"]).or_else(""),
            :long => Maybe(params["delivery_long"]).or_else(""),
            :address => params["delivery-address"] ? (params["apartment-no"] + ", " + params["landmark"] + ", " + params["delivery-address"] + ", " + (Maybe(params["postal_code"]).or_else(""))) : "",
         
            :delivery_charge => Maybe(params["estimated_fare"]).or_else("")
          }
          @transaction = @current_community.transactions.find(tx_response[:data][:transaction][:id])
          @listing = @transaction.listing

          @transaction.add_checkout_fieds_to_transaction(@order_request_data["checkout_fields"], @current_community)
          # @count = Message.where(conversation_id: @transaction.conversation_id).count
      
          # if (@current_community.id == 212 || @current_community.id == 1) && @listing.unit_type.to_s == "unit" 
          #   sendTaskToTookan
          # end
            # xhr_json_redirect person_transaction_path(@current_user, tx_response[:data][:transaction][:id], :app_session_token => params[:app_session_token], :payment_status => "success")
            hsh = {}
            hsh[:status] = 200
            hsh[:success] = "Success"
            hsh[:redirect_link] = payment_success_app_pages_path(:payment_callback => "success", :transaction_id => @transaction.id)
            render :json => hsh.to_json
        else
          render json: {
            op_status_url: transaction_op_status_path(tx_response[:data][:gateway_fields][:process_token]),
            op_error_msg: t("error_messages.#{gateway}.generic_error")
          }
        end
      end
    
      def xhr_json_redirect(redirect_url)
        if request.xhr?
          render json: { redirect_url: redirect_url }
        else
          redirect_to redirect_url
        end
      end
 
    def render_error_response(is_xhr, error_msg, redirect_params)
      hsh = {}
      hsh[:status] = 400
      hsh[:message] = error_msg
      hsh[:redirect_link] = payment_error_app_pages_path(:payment_callback => "error", :error => error_msg)
      render :json => hsh.to_json
    end   


    def add_defaults(params:, shipping_enabled:, pickup_enabled:)
      default_shipping =
        case [shipping_enabled, pickup_enabled]
        when [true, false]
          {delivery: :shipping}
        when [false, true]
          {delivery: :pickup}
        when [false, false]
          {delivery: nil}
        else
          {}
        end
  
      params.merge(default_shipping)
    end  

    def razorapay_api 
      RazorpayService::API::Api.wrapper
    end   
    
end
