class Api::V1::AppListingsController < Api::V1::ApplicationController
    before_action :authenticate_api_user, only: []
    before_action :check_token, only: []
    






    #//-------------------get all enable listing-----------------------------//
    #category_id, listing_shape_id, community_id, session_token, latitude, longitude, distance, price_min, price_max
    def get_all_listing
        begin
            if !params[:community_id] || !params[:session_token] || !params[:latitude] || !params[:longitude]
                @error ={
                    message: "Parameter missing",
                    status:  400
                }
                raise @error
            end
            params[:page] = 1 unless params[:page].present?
            if params[:session_token].present?
                @active_app_session = TbActiveAppSession.where("community_id= :cid AND session_token = :sid", cid: params[:community_id], sid: params[:session_token])
                if @active_app_session.empty? 
                    @error = {
                        message: "Session expired. Please logout and login again.",
                        status: 101
                    }
                    raise @error
                end
            end
            @community = Community.find_by_id(params[:community_id])
            unless @community.present?
                @error ={
                    message: "Something went wrong.",
                    status:  400
                }
                raise @error
            end
            if requiresJSONParse(params[:category_ids])

                params[:category_ids] = JSON.parse(params[:category_ids])

            end
            if requiresJSONParse(params[:listing_shape_ids])

                params[:listing_shape_ids] = JSON.parse(params[:listing_shape_ids])

            end
            if requiresJSONParse(params[:custom_fields])
                params[:custom_fields] = JSON.parse(params[:custom_fields])
            end   
            puts " the community id is : " , @community
            listing_ids = @community.listings.where("state = ?","approved").where(:deleted => false).currently_open.by_category_id(params[:category_ids]).by_listing_shape(params[:listing_shape_ids]).by_price_range(params[:price_min], params[:price_max]).by_title(params[:search_text]).ids
            puts " the listings ids are : "  ,listing_ids
            puts " the custom fields in : " , params[:custom_fields]
            custom_field_listing_ids = []
            if params[:custom_fields].present?
                params[:custom_fields].each do |cus_field|
                    custom_field = @community.custom_fields.find_by_id(cus_field[:id])
                    custom_field_listing_ids += custom_field.get_listing_ids(cus_field[:values]) if custom_field.present?
                end
                final_listing_ids = listing_ids & custom_field_listing_ids
            else
                final_listing_ids = listing_ids
            end        
            puts "the final listing ids are:  " , final_listing_ids    
            listiing_ids_by_lat_long = Location.where(:listing_id => final_listing_ids).loc_by_lat_long(params[:latitude], params[:longitude], params[:distance] || 1000).map(&:listing_id)
            puts " the listings ids by lat long " , listiing_ids_by_lat_long
            puts " the params are , latitude :  " , params[:latitude ] , " longitude : " , params[:longitude] , " distance : " , params[:distance]
            @listing_data = Listing.where(:id => listiing_ids_by_lat_long).by_order(params[:order_by],params[:order]).paginate(page: params[:page], per_page: 10)
             
           puts " the listing data is : " , @listing_data
            if @listing_data.empty?
                success_msg([])
            else
                render "app_listings/listing"
            end
        rescue => e
            puts "the error is : " , e
            show_error!(@error.present? ? @error[:message] : e.message, @error.present? ? @error[:status] : 400)
        end
    end
    #//-------------------end------------------------//








    #//---------------------------- show listing of author ---------------------------//
    def get_listing_details
        begin
            if !params[:community_id] || !params[:session_token] || !params[:person_id] || !params[:listing_id]
                @error ={
                    message: "Parameter missing",
                    status:  400
                }
                raise @error
            end
            if params[:session_token].present? && params[:person_id].present?
                @active_app_session = TbActiveAppSession.where("community_id= :cid AND session_token = :sid AND person_id = :pid", cid: params[:community_id], sid: params[:session_token], pid: params[:person_id])

                if @active_app_session.empty? 
                    @error ={
                        message: "Session expired. Please logout and login again.",
                        status: 101
                    }
                    raise @error
                end
            end
            @community = Community.find_by_id(params[:community_id])
            unless @community.present?
                @error ={
                    message: "Something went wrong.",
                    status:  400
                }
                raise @error
            end
            @listing_data = @community.listings.where(:id => params[:listing_id])

            if @listing_data.empty?
                success_msg([])
            else
            render "app_listings/listing_detail"
            end

        rescue => e
            show_error!(@error.present? ? @error[:message] : e.message, @error.present? ? @error[:status] : 400)
        end
    end

    #//--------------------------delete comment----------------------------//

    def delete_comment

        begin
            if !params[:community_id] || !params[:session_token] || !params[:comment_id] || !params[:listing_id]
                @error ={
                    message: "Parameter missing",
                    status:  400
                }
                puts "parameter were not present"
                raise @error
            end

            @active_app_session = TbActiveAppSession.where("community_id= :cid AND session_token = :sid", cid: params[:community_id], sid: params[:session_token])

            if @active_app_session.empty? 
                @error ={
                    message: "Session expired. Please logout and login again.",
                    status: 101
                }
                raise @error
            end

            @comment = Comment.find(params[:comment_id])

            raise "No such comment id present " unless @comment.present?
            Comment.delete(params[:comment_id])
            success_msg()

        rescue => e

            show_error!(@error.present? ? @error[:message] : e.message, @error.present? ? @error[:status] : 400)

        end



    end

    def message_read

        begin 


            if !params[:session_token] || !params[:conversation_id] || !params[:person_id]
                
                raise "Parameter missing"
            end

            @active_app_session = TbActiveAppSession.where("session_token= :sid AND person_id = :pid",sid: params[:session_token], pid: params[:person_id])

            if @active_app_session.empty? 
             
                @error ={
                    message: "Session expired. Please logout and login again.",
                    status: 101
                }
                raise @error
            end

        #    Conversation.find_by(id: params[:conversation_id]).mark_as_read(params[:person_id])
           
            success_msg()


        rescue => e

            show_error!(@error.present? ? @error[:message] : e.message, @error.present? ? @error[:status] : 400)
            
       
            
        end


    end







    #------------------------------end delete comment-----------------------//

    def checkout

        begin

            if !params[:community_id] || !params[:session_token] || !params[:person_id] || !params[:listing_id] || !params[:quantity] || !params[:message] 
                
                raise "Parameter missing"
            end

            @active_app_session = TbActiveAppSession.where("community_id= :cid AND session_token = :sid AND person_id = :pid", cid: params[:community_id], sid: params[:session_token], pid: params[:person_id])

            if @active_app_session.empty? 
             
                @error ={
                    message: "Session expired. Please logout and login again.",
                    status: 101
                }
                raise @error
            end

        puts "params are present " , params
        @current_community = @active_app_session.last.community
        listing_data = Listing.find(params[:listing_id])
        params[:end_on] = (params[:end_on].to_date + 1.day).strftime("%Y-%m-%d") if params[:end_on].present? && listing_data.unit_type == "day".to_sym
        booking_fields = Maybe(params).slice(:start_on, :end_on).select { |booking| booking.values.all? }.or_else({})
        
        puts "the booking fields are : " , booking_fields

        sent_tookan = false

        if(params[:send_to_tookan] == 1 || params[:send_to_tookan] == true)
        sent_tookan = true
        end

        returnVal,tookanVal = checkoutAction(params[:message],params[:community_id],params[:person_id],params[:listing_id],params[:quantity],booking_fields,params[:delivery_address] || "",params[:delivery_latitude] || "",params[:delivery_longitude] || "" , sent_tookan , params[:delivery_charge] || "0")
        
        puts "the return value is : " , returnVal

        @tookan_was_required = sent_tookan == true ? true : false 
        @tookan_task_sent = tookanVal == true ? true : false 

        if returnVal
            render "app_listings/checkout"

        else
            raisse "Checkout Failed"
        end
        

        rescue => e
            show_error!(@error.present? ? @error[:message] : e.message, @error.present? ? @error[:status] : 400)
        end
    end

    #------------------------------end delete comment-----------------------//

    def get_active_filters
        begin
            if !params[:community_id] || !params[:session_token]
                @error ={
                    message: "Parameter missing",
                    status:  400
                }
                raise "Parameter Missing"
            end
            if params[:session_token].present?
                @active_app_session = TbActiveAppSession.where("community_id= :cid AND session_token = :sid", cid: params[:community_id], sid: params[:session_token])
                if @active_app_session.empty? 
                    @error ={
                        message: "Session expired. Please logout and login again.",
                        status: 101
                    }
                    raise "Session Expired. Please logout and login again"
                end
            end
            @current_community = Community.find_by_id(params[:community_id])
            unless @current_community.present?
                @error ={
                    message: "Something went wrong.",
                    status:  400
                }
                raise @error
            end
            render "app_listings/get_active_filters"
        rescue => e
            show_error!(@error.present? ? @error[:message] : e.message, @error.present? ? @error[:status] : 400)
        end
    end

    def image_config

        begin

            if !params[:session_token]
                @error ={
                    message: "Parameter missing",
                    status:  400
                }
                raise @error
            end
            @active_app_session = TbActiveAppSession.where("session_token = :sid", sid: params[:session_token])
            if @active_app_session.empty? 
                @error ={
                    message: "Session expired. Please logout and login again.",
                    status: 101
                }
                raise @error
            end

            @s3 =  S3Uploader.new

            puts "@s is " , @s3

            @s3_fields = @s3.fields
            @fields =  OpenStruct.new(@s3_fields)
            @profile_fields_temp = @s3.profile_page_fields
            @profile_fields = OpenStruct.new(@profile_fields_temp)
            @checkout_page_fields_temp = @s3.checkout_page_fields
            @checkout_fields = OpenStruct.new(@checkout_page_fields_temp)
            main_key =  @fields.key 
            arr = main_key.split('/')
            arr.pop(2)
            final_key = arr.join('/')
            @fields.key = final_key

            puts "the fields are : " , @fields


            @fields_final = OpenStruct.new()

        

            if params[:for_landing_page]

                @fields_final.key = @fields.landing_key
                @fields_final.policy = @fields.landing_policy
                @fields_final.signature = @fields.landing_signature
                @fields_final.success_action_status = @fields.success_action_status
                @fields_final.acl = @fields.acl
                @fields_final.AWSAccessKeyID = @fields.AWSAccessKeyID
                
            elsif params[:for_profile]
    
                @fields_final.key = @profile_fields.key
                @fields_final.policy = @profile_fields.policy
                @fields_final.signature = @profile_fields.signature
                @fields_final.success_action_status = @profile_fields.success_action_status
                @fields_final.acl = @profile_fields.acl
                @fields_final.AWSAccessKeyID = @profile_fields.AWSAccessKeyID

            elsif params[:for_checkout_fields]
    
                @fields_final.key = @checkout_fields.key
                @fields_final.policy = @checkout_fields.policy
                @fields_final.signature = @checkout_fields.signature
                @fields_final.success_action_status = @checkout_fields.success_action_status
                @fields_final.acl = @checkout_fields.acl
                @fields_final.AWSAccessKeyID = @checkout_fields.AWSAccessKeyID

            else

                @fields_final.key = @fields.key
                @fields_final.policy = @fields.policy
                @fields_final.signature = @fields.signature
                @fields_final.success_action_status = @fields.success_action_status
                @fields_final.acl = @fields.acl
                @fields_final.AWSAccessKeyID = @fields.AWSAccessKeyID
                
            end

            puts " @fields final are : " ,@fields_final

            @aws_access_key_id = APP_CONFIG.aws_access_key_id
            @aws_secret_access_key = APP_CONFIG.aws_secret_access_key
            @bucket = APP_CONFIG.s3_upload_bucket_name
            @expiration = 20.hours.from_now
            @bucket_url = @s3.url
            if params[:for_profile]
                @bucket = "yelodotred"
                @bucket_url = @bucket_url.sub("rentals-temp","yelodotred")
            end  
            render "app_listings/image_config"
        rescue => e
            show_error!(@error.present? ? @error[:message] : e.message, @error.present? ? @error[:status] : 400)
        end

    end

    def my_listings
        begin
            if !params[:community_id] || !params[:session_token]
                @error ={
                    message: "Parameter missing",
                    status:  400
                }
                raise "Parameter missing"
            end
            params[:page] = 1 unless params[:page].present?
            @active_app_session = TbActiveAppSession.where("community_id= :cid AND session_token = :sid", cid: params[:community_id], sid: params[:session_token])

            if @active_app_session.empty? 
                @error ={
                    message: "Session expired. Please logout and login again.",
                    status: 101
                }
                raise @error
            end
            listing_ids = @active_app_session.last.person.listings.where(:deleted => false).currently_open.ids
            #@listing_data = Listing.where(:id => listing_ids).paginate(page: params[:page], per_page: 10)
            @listing_data = Listing.where(:id => listing_ids)

            if @listing_data.empty?
                success_msg([])
            else
                render "app_listings/listing"
            end
        rescue => e
            show_error!(@error.present? ? @error[:message] : e.message, @error.present? ? @error[:status] : 400)
        end

    end

    def add_listing
        begin
            if !params[:community_id] || !params[:person_id]
                @error ={
                    message: "Parameter missing",
                    status:  400
                }
                raise @error
            end
            @active_app_session = TbActiveAppSession.where("community_id= :cid AND person_id = :pid", cid: params[:community_id], pid: params[:person_id])

            if @active_app_session.empty? 
                @error ={
                    message: "Session expired. Please logout and login again.",
                    status: 101
                }
                raise @error
            end

            puts " the params are  :  " , params

            if requiresJSONParse(params[:listing])

                params[:listing] = JSON.parse(params[:listing])

            end

            if requiresJSONParse(params[:custom_fields])

                params[:custom_fields] = JSON.parse(params[:custom_fields])

            end

            if requiresJSONParse(params[:listing_images])

                params[:listing_images] = JSON.parse(params[:listing_images])

            end
            
            if requiresJSONParse(params[:delivery_methods])

                params[:delivery_methods] = JSON.parse(params[:delivery_methods])
                params[:listing][:delivery_methods] = params[:delivery_methods]

            end


            
            puts " the final params are : " , params


            @current_community = Community.find(params[:community_id])

            puts "the current community found is : " , @current_community

            # puts "the params[:listing is ] " , params[:listing]
            # puts " the params " , params[:custom_fields]
            params[:listing].delete("origin_loc_attributes") if params[:listing][:origin_loc_attributes][:address].blank? 
            puts "getting the shape"         
            shape = get_shape(Maybe(params)[:listing][:listing_shape_id].to_i.or_else(nil))
            listing_uuid = UUIDUtils.create
            result = ListingFormViewUtils.build_listing_params(shape, listing_uuid, params, @current_community)
        
            unless result.success
                @error ={
                    message: "Something went wrong.",
                    status: 400
                }
                raise @error                
            end    
            @listing = Listing.new(result.data) 
            # puts "the new listing onject is : ", @listing
            ActiveRecord::Base.transaction do
                puts " inside activerecord base transaction"
                @listing.author = Person.find_by(id: params[:person_id])
                if @listing.save
                    if params[:listing].present?
                        params[:listing][:blocked_dates].each {|a| "#{@listing.listing_blockdates.create(:date => a)}"} if params[:listing][:blocked_dates].present?
                    end
                #   puts " the custom  fields received is :  .... " , params.to_unsafe_hash[:custom_fields]
                  @listing.upsert_field_values!(params.to_unsafe_hash[:custom_fields])
        
                  #@listing.reorder_listing_images(params, params[:person_id])
                #   notify_about_new_listing
                #   begin
                #     lcommunity_id = @listing.community_id
                #     lcommunity = Community.find_by(id: lcommunity_id)
                #     ladmin = Person.find_by(community_id: lcommunity_id,is_admin: 1)
                #     ladminEmailAddress = Email.find_by(person_id: ladmin.id)[:address]
                #     lposter = Email.find_by(person_id: @listing[:author_id])[:address]
                #     llink = lcommunity[:domain] + '/listings/' + @listing[:id].to_s + "-" + @listing[:title] 
                #     if UserMailer::Mandrill.new_listing_added(lcommunity[:ident],ladminEmailAddress,lposter,@listing[:title],llink)       
                #       puts " Mail was send "                                    
                #     else                 
                #       puts " Mail was not sent .."                                
                #     end                    
                #   rescue => exception          
                #     puts " Email not send... "                    
                #   end                           
                if shape.booking?
                    anchor = shape.booking_per_hour? ? 'manage-working-hours' : 'manage-availability'
                    @listing.working_hours_new_set(force_create: true) if shape.booking_per_hour?
                  end
                else
                    # puts "The error is : "  ,  @listing.errors.full_messages
                    @error ={
                        message: "Listing could not be saved.",
                        status: 400
                    }
                    raise @error
                end
              end 
            addImage(params[:listing_images],@listing.id,params[:person_id])   
            success_msg([], "New listing added.")
        rescue => e
            puts " the error is : " , e
            show_error!(@error.present? ? @error[:message] : e.message, @error.present? ? @error[:status] : 400)
        end

    end

    def addPersonImage
        begin
            if !params[:image_url] || !params[:person_id] || !params[:session_token]
                @error ={
                    message: "Parameter missing",
                    status:  400
                }
                raise "Parameter Missing"
            end
            @active_app_session = TbActiveAppSession.where("person_id = :pid AND session_token = :sid", pid: params[:person_id], sid: params[:session_token])

            if @active_app_session.empty? 
                @error ={
                    message: "Session expired. Please logout and login again.",
                    status: 101
                }
                raise @error
            end
            @person = Person.find_by(id: params[:person_id])
            @person.picture_from_url(params[:image_url])
            success_msg([])
        rescue => e
            show_error!(@error.present? ? @error[:message] : e.message, @error.present? ? @error[:status] : 400)
        end

    end

    def addImage(params,listing_id,person_id) 

        #requires path , filename , listing_id , person_id 
        
        begin

            params.each do |p|
                addListingImages(p,listing_id,person_id) 
            end

           
           

        rescue => e  

            show_error!(@error.present? ? @error[:message] : e.message, @error.present? ? @error[:status] : 400)

        end
        



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
    
    def addListingImages(params,listing_id,person_id) 


        url = escape_s3_url(params[:path], params[:filename])

        if !url.present?
          puts " No URL is provided...."
        end
    
        add_image(listing_id, {}, url,person_id)

    end

    def escape_s3_url(path, filename)
        escaped_filename = CGI.escape(filename.encode('UTF-8')).gsub('+', '%20').gsub('%7E', '~')
        path.sub("${filename}", escaped_filename)
      end
    
      def add_image(listing_id, params, url, person_id)
        listing_image_params = params.merge(
          author_id: person_id,
          listing_id: listing_id
        )
    
        new_image(listing_image_params, url)
      end
    
      # Create a new image object
      def new_image(params, url)
        listing_image = ListingImage.new(params)
    
        listing_image.image_downloaded = if url.present? then false else true end
    
        if listing_image.save
          if !listing_image.image_downloaded
            puts "The image is not downloaded yet"
            #logger.info("Asynchronously downloading image", :start_async_image_download, listing_image_id: listing_image.id, url: url, params: params)
            Delayed::Job.enqueue(DownloadListingImageJob.new(listing_image.id, url), priority: 1)
          else
            puts "Listing image is already downloaded"
            #logger.info("Listing image is already downloaded", :image_already_downloaded, listing_image_id: listing_image.id, params: params.except(:image))
          end
        else
          puts "Saving listing image field"
          #logger.error("Saving listing image failed", :saving_listing_image_failed, params: params, errors: listing_image.errors.messages)
          #render json: {:errors => listing_image.errors.full_messages}, status: 400, content_type: 'text/plain'
        end
      end


    
    def action_success(data = HashWithIndifferentAccess.new, msg =" Action complete", status = 200)
        suss_hash            = HashWithIndifferentAccess.new
        suss_hash[:message]  = msg
        suss_hash[:status]   = status
        suss_hash[:data]     = data
    
        render :json => suss_hash.to_json
      end

    def checkoutAction(messageTo,community_id,person_id,listing_id,unit_quantity,booking_fields,address,latitude,longitude,send_to_tookan,delivery_charge)

        listing_model = Listing.find_by(id: listing_id)
        current_user = Person.find_by(id: person_id)
        puts " the listing model is :  " , listing_model.quantity_selector
        current_community = current_user.community
        author_model = listing_model.author
        message = messageTo
        success = true
        additonalPrice = 0
        is_booking = date_selector?(listing_model)
        quantity = calculate_quantity(tx_params: {
                                            quantity: unit_quantity,
                                            start_on: booking_fields.dig(:start_on),
                                            end_on: booking_fields.dig(:end_on)
                                          },
                                          is_booking: is_booking,
                                          unit: listing_model.unit_type&.to_sym)

        puts "is_booking : " , is_booking
        puts "quantity is : " , quantity
        price = calculate_additional_checkout_price(params["checkout_fields"])
        Result.all(

           ->() {
               TransactionService::API::Api.processes.get(community_id: community_id, process_id: listing_model.transaction_process_id)
           },
           ->(process){

        is_booking = date_selector?(listing_model)
        quantity = calculate_quantity(tx_params: {
                                            quantity: unit_quantity,
                                            start_on: booking_fields.dig(:start_on),
                                            end_on: booking_fields.dig(:end_on)
                                          },
                                          is_booking: is_booking,
                                          unit: listing_model.unit_type&.to_sym)

        transaction_service.create(
            {
              transaction: {
                community_id: current_community.id,
                community_uuid: current_community.uuid_object,
                listing_id: listing_id,
                listing_uuid: listing_model.uuid_object,
                listing_title: listing_model.title,
                starter_id: current_user.id,
                starter_uuid: current_user.uuid_object,
                listing_author_id: author_model.id,
                listing_author_uuid: author_model.uuid_object,
                unit_type: listing_model.unit_type,
                unit_price: listing_model.price,
                unit_tr_key: listing_model.unit_tr_key,
                availability: listing_model.availability,
                listing_quantity: quantity,
                content: message,
                starting_page: ::Conversation::PAYMENT,
                booking_fields: booking_fields,
                payment_gateway: :none, 
                payment_process: process.process,
                additional_info: '',
                additional_price: additonalPrice,
                checkout_field_price_cents: price || 0
              }
            })

           }               
        ).on_success{ |(process, tx) |

            puts "firing after create action " , process , " th rx is " , tx  

            @transaction_t = tx[:transaction]

            after_create_actions!(process: process, transaction: tx[:transaction], community_id: community_id)

            puts " action firing complete"

        }.on_error {

          success = false

        }

        @tookanSuccess = true 

        puts " the transaction is : " , @transaction_t

         if(success == true )
             
                 if(send_to_tookan && listing_model.unit_type.to_s == "unit")
                 @tookanSuccess = sendTaskToTookan(listing_model,@transaction_t,current_user,address,longitude,latitude,current_community,delivery_charge)
                 end

                end

        return success,@tookanSuccess

                

    end

    def calculate_quantity(tx_params:, is_booking:, unit:)
        if is_booking
            tx_params[:start_on] =  Date.parse  tx_params[:start_on]
            tx_params[:end_on]  = Date.parse  tx_params[:end_on]
            puts tx_params[:start_on].class
            puts tx_params[:start_on]
            DateUtils.duration(tx_params[:start_on], tx_params[:end_on])
        else
          tx_params[:quantity] || 1
        end
    end


    def date_selector?(listing)
    
      x = [:day, :night].include?(listing.quantity_selector&.to_sym)

      puts " the date selector is present ??? " , x

      x
    end

    def after_create_actions!(process:, transaction:, community_id:)
        if requiresJSONParse(params[:checkout_fields]).present?
            params[:checkout_fields] = JSON.parse(params[:checkout_fields])
        end
        puts "arguments are : " , process , "  trax " , transaction , " community : " , community_id
        transaction.add_checkout_fieds_to_transaction(params[:checkout_fields], @current_community)
        case process.process
        when :none
          # TODO Do I really have to do the state transition here?
          # Shouldn't it be handled by the TransactionService
          TransactionService::StateMachine.transition_to(transaction[:id], "free")
    
          transaction = Transaction.find(transaction[:id])

          @conversation = transaction.conversation
    
          #Delayed::Job.enqueue(MessageSentJob.new(transaction.conversation.messages.last.id, community_id))
        else
          raise NotImplementedError.new("Not implemented for process #{process}")
        end
      end

  def transaction_service
    TransactionService::Transaction
  end

  def requiresJSONParse(unit)

    begin

      JSON.parse(unit)

      return true

    rescue => e

      return false

    end

  end

  def get_shape(listing_shape_id)
    @current_community.shapes.find(listing_shape_id)
  end


  def sendTaskToTookan(listing,transaction,person,address,longitude,latitude,community,delivery_charge)

    @listing = listing
    @transaction = transaction
    @current_user = person
    @delivey_address = address 
    @delivery_longitude = longitude 
    @delivery_latitude = latitude
    @current_community = community  
    @delivery_charge = delivery_charge


    puts @listing,@transaction,@current_user,@delivey_address,@delivery_longitude,@delivery_latitude,@current_community

    @url = "https://api.tookanapp.com/v2/create_task" 

    if Rails.env.production?
      @api_key = APP_CONFIG.tookan_api_key
      #pmp api keyy
    else
      @api_key = ""
    end
          
    @location = Location.find_by(listing_id: @listing.id) 
    @listingAuthor = Person.find_by(id: @listing.author_id) 
    
    uri = URI(@url) 
    https = Net::HTTP.new(uri.host, uri.port) 
    https.use_ssl = true 
    req = Net::HTTP::Post.new(uri.path, {'Content-Type' =>'application/json'}) 
    @time = Time.new 
    @time = @time - 4*60*60 
    @time = @time + 60*60 
    @pickupTime = @time 
    @time = @time + 3*60*60 
    @item = @listing.title.to_s 
    @price = @listing.price.to_s 
    @quantity = @transaction.listing_quantity.to_s 
    
    req.body = { 
    :api_key => @api_key,
    :order_id => @listing.id, 
    :job_description => "PMP Markets , Pickup and Deliver Item Task ", 
    :customer_email => Email.find_by(person_id: @current_user.id)[:address], 
    :customer_username => @current_user.username, 
    :customer_phone => @current_user[:phone_number] || '', 
    :customer_address => @delivey_address, 
    :latitude =>  @delivery_latitude, 
    :longitude => @delivery_longitude, 
    :job_delivery_datetime => @time, 
    :custom_field_template => "Order", 
    :meta_data => "[{'label':'Item','data': '#{@item}' },{'label':'Price','data':'#{@price} #{@transaction.unit_price_currency}'},{'label':'Quantity','data':'#{@quantity}'}]", 
    :team_id => 134756, 
    :auto_assignment => 1, 
    :has_pickup => 1, 
    :layout_type => 0, 
    :tracking_link => 0, 
    :timezone => 240, 
    :p_ref_images => '["http://tookanapp.com/wp-content/uploads/2015/11/logo_dark.png","http://tookanapp.com/wp-content/uploads/2015/11/logo_dark.png"]', 
    :ref_images => '["http://tookanapp.com/wp-content/uploads/2015/11/logo_dark.png","http://tookanapp.com/wp-content/uploads/2015/11/logo_dark.png"]', 
    :notify => 1, 
    :tags => 'PMP Markets', 
    :geofence => 0, 
    :job_pickup_phone => @listingAuthor[:phone_number] || '', 
    :job_pickup_name => @listingAuthor[:given_name], 
    :job_pickup_address => @location[:google_address], 
    :job_pickup_latitude => @location[:latitude], 
    :job_pickup_longitude => @location[:longitude], 
    :job_pickup_datetime => @pickupTime, 
    :pickup_custom_field_template => "Order", 
    :pickup_meta_data => "[{'label':'Item','data': '#{@item}' },{'label':'Price','data':'#{@price} #{@transaction.unit_price_currency}'},{'label':'Quantity','data':'#{@quantity}'}]", 
    :ride_type => 0, 
    
    
    :has_delivery => 1, 
    }.to_json 
    
    
    puts " the request body is : " , req.body
    res = https.request(req) 
    puts "the response was ...... " + res.body 
    @tookanRes = JSON.parse(res.body) 
    if @tookanRes["status"] == 200 

    puts " the status of Hit is : " , @tookanRes["status"]
    
    TookanTask.create( 
    :listing_id => @listing.id, 
    :transaction_id => @transaction.id, 
    :buyer_id => @current_user.id, 
    :seller_id => @listingAuthor.id, 
    :tookan_job_id => @tookanRes["data"]["job_id"], 
    :tookan_pickup_id => @tookanRes["data"]["pickup_job_id"], 
    :tookan_delivery_id => @tookanRes["data"]["delivery_job_id"], 
    :job_pickup_address => @location[:google_address], 
    :job_delivery_address => @delivey_address, 
    :task_delivery_charges => @delivery_charge, 
    :tookan_api_user_id => @current_community[:user_id], 
    :job_delivery_latitude => @delivery_latitude, 
    :job_delivery_longitude => @delivery_longitude, 
    :job_pickup_latitude => @location[:latitude], 
    :job_pickup_longitude => @location[:longitude], 
    :pickup_required => 1, 
    :delivery_required => 1 
    ) 
    
    puts " the task creation is successfull" 

    return true
    
    #UserMailer::Mandrill::new_tookan_task_creation("nikhil.sharma@jungleworks.com",@tookanRes,@tookanRes["status"]) 
    else 
         return false 
    end 
    
end

    def get_enable_listing(community_id)
        Listing.select("li.id AS listing_id,
            li.community_id,
            li.author_id ,
            li.title,
            li.times_viewed,
            li.language,
            li.sort_date,
            li.description,
            li.destination,
            li.valid_until,
            li.share_type_id,
            li.listing_shape_id,
            li.transaction_process_id,
            li.price_cents,
            li.currency,
            li.quantity,
            li.unit_type,
            ls.price_enabled,
            ls.shipping_enabled,
            ls.name,
            ls.sort_priority,
            lu.quantity_selector,
            lu.kind
            ").joins("LEFT JOIN listing_shapes ls  ON li.listing_shape_id = ls.id 
            LEFT JOIN listing_units lu ON lu.listing_shape_id= ls.id").from("listings li").where("li.community_id = :cid AND li.is_approved = 1 AND li.deleted =0", cid: community_id )
    end

end
