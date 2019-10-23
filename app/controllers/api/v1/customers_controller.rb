class Api::V1::CustomersController < Api::V1::ApplicationController
    before_action :authenticate_api_user, only: []
    before_action :check_token, only: []
    include Analytics


    #Facebook login-> community_id, device_token, device_type, email, fb_id, given_name, family_name, image
    def fb_login
        begin
            raise "Parameter missing." if !params[:community_id] || !params[:device_token] || !params[:device_type] || !params[:email] || !params[:fb_id] || !params[:given_name] || !params[:family_name]
            @current_community = Community.find_by_id(params[:community_id])
            raise "Something went wrong." unless @current_community.present?
            username = UserService::API::Users.username_from_fb_data(
                username: "",
                given_name: params[:given_name],
                family_name: params[:family_name],
                community_id: @current_community.id)
            @has_signup = 0
            if @current_community.emails.find_by_address(params[:email]).present?
                @email = @current_community.emails.find_by_address(params[:email])
                @current_user = @email.person
            elsif @current_community.people.find_by_facebook_id(params[:fb_id]).present?
                @current_user = @current_community.people.find_by_facebook_id(params[:fb_id])
            else
                @current_user = @current_community.people.create!(facebook_id: params[:fb_id], given_name: params[:given_name], family_name: params[:family_name], password: Devise.friendly_token[0,20], username: username, locale: I18n.locale, test_group_number: 1 + rand(4))
                @email = @current_community.emails.create!(address: params[:email], send_notifications: true, person: @current_user, :confirmed_at => Time.now)
                @current_user.set_default_preferences
                @current_user.preferences["email_from_admins"] = false
                @current_user.save      
                if params[:image].present?
                    @current_user.picture_from_url(params[:image])              
                end    
                CommunityMembership.create(person: @current_user, community: @current_community, status: "pending_consent")
                if APP_CONFIG.skip_email_confirmation
                    @email.confirm!
                else
                    Email.send_confirmation(@email, @current_community)
                end 
                @has_signup = 1
            end
            str = @current_user.id + @current_community.id.to_s + Time.now.to_s
            @token = Digest::SHA256.hexdigest(str)
            TbActiveAppSession.where(device_token: params[:device_token]).update_all(device_token: "") if params[:device_token].present?
            TbActiveAppSession.create!(person_id: @current_user.id, community_id: @current_community.id, session_token: @token, device_token: params[:device_token], device_type: params[:device_type], refreshed_at: Time.now)
            if @has_signup == 1
                response = {
                    person_id:     @current_user.id,
                    community_id:  @current_community.id,
                    session_token: @token,
                    has_signup: @has_signup
                }
                success_msg(response)
            else
                @notification_count = InboxService.notification_count(@current_user.id,  @current_community.id)
                render "app_listings/user_detail"
            end
        rescue Exception => e
            show_error!((@error.present? ? @error[:message] : e.message) , (@error.present? ? @error[:status] : 400))
        end
    end

    def check_policies
        begin
            raise "Parameter missing." if !params[:session_token] || !params[:consent]
            current_user_session = TbActiveAppSession.where(session_token: params[:session_token])
            unless current_user_session.present?
                @error = HashWithIndifferentAccess.new
                @error[:message] = "Session expired. Please logout and login again."
                @error[:status] = 101
                raise @error
            end
            @current_community = current_user_session.last.community
            @current_user = current_user_session.last.person
            attrs = {
                consent: APP_CONFIG.consent.presence || "SHARETRIBE1.0",
                status: "accepted"
            }
            @current_user.community_membership.update_attributes!(attrs)
            @has_signup = 0
            @token = params[:session_token]
            @notification_count = InboxService.notification_count(@current_user.id,  @current_community.id)
            Delayed::Job.enqueue(CommunityJoinedJob.new(@current_user.id, @current_community.id))
            Delayed::Job.enqueue(SendWelcomeEmail.new(@current_user.id, @current_community.id), priority: 5)      
            render "app_listings/user_detail"
        rescue Exception => e
            show_error!((@error.present? ? @error[:message] : e.message) , (@error.present? ? @error[:status] : 400))
        end
    end

# //--------------------------------cutsomer signup Api ------------------------------//
    def customer_signup
        begin
        if (!params[:device_type]) || (params[:device_type] != "ANDROID" && params[:device_type] != "IOS" &&  params[:device_type] !="WEB") || (params[:device_type] == "ANDROID" && !params[:customer_data])
            @error ={
                message: "Parameter missing",
                status:  400
            }
            raise @error
        end

        puts " chcking data is present..."

        if params[:customer_data].present? 
            params[:customer] = JSON.parse(params[:customer_data])
        end
        puts " the params are : " , params
        puts "data is present....."
        puts " the params are : " , params[:customer]
        community = Community.find_by_id(params[:community_id])
        unless Community.find_by_id(params[:community_id]).present?
            puts "Community doesn't exist"
            @error = {
                message:  "Something went wrong.",
                status:   400
            }
            raise @error
        end
        if community.people.where(:username => params[:username]).present?
            @error = {
                message:  "username already exits",
                status:   400
            }
            raise @error
        end
        if community.emails.where(:address => params[:email]).present?
            @error = {
                message:  "email already exits",
                status:   400
                }
                raise @error
            end  

        puts "the params are : " , params
        
        params[:customer][:locale]     = params[:locale] || APP_CONFIG.default_locale
        params[:customer][:given_name] = params[:given_name]
        params[:customer][:family_name] = params[:family_name]
        params[:customer].delete("device_token")
        params[:customer].delete("device_type")
        params.delete("custom_field_values_attributes")
        device_token = params[:device_token]

        puts " the devise token completed... "
        ActiveRecord::Base.transaction do
            @person = Person.create!(people_params)
            @current_communities = find_community_by_id(params[:community_id])
            # We trust that Facebook has already confirmed these and save the user few clicks
            email = Email.create!(:address => params[:email], :send_notifications => true, :person => @person, community_id: params[:community_id])
            @person.set_default_preferences
            # By default no email consent is given
            @person.preferences["email_from_admins"] = false
            #@person.email << email
            @person.save
      
            CommunityMembership.create(person: @person, community: @current_communities, status: "pending_email_confirmation", consent: "SHARETRIBE1.0")

            str = @person.id + params[:community_id].to_s + Time.now.to_s
            token = Digest::SHA256.hexdigest(str)
            TbActiveAppSession.where(device_token: device_token).update_all(device_token: "") if device_token.present?
            TbActiveAppSession.create!(person_id: @person.id, community_id: params[:community_id], session_token: token, device_token: device_token, device_type: params[:device_type], refreshed_at: Time.now)
            response ={
                person_id:     @person[:id],
                community_id:  params[:community_id],
                session_token: token
            }
            puts "the person email is : " , @person.email
            email = Email.find_by(address: @person.email)
            puts " the email is : " , email.attributes
            if APP_CONFIG.skip_email_confirmation
                email.confirm!
              else
               Email.send_confirmation(email, community)
            end
            puts " everthing done.... " , response
            success_msg(response)
        end

        rescue => e
            show_error!(@error.present? ? @error[:message] : e.message, @error.present? ? @error[:status] : 400)
        end
    end
    #//------------------------------end-------------------------//








    
    #//------------------------login via person id-----------------------//

    def login_via_person_id
        begin
            if !params[:person_id] || !params[:community_id] || !params[:session_token] || !params[:device_type] || (params[:device_type] != "ANDROID" && params[:device_type] != "IOS" &&  params[:device_type] !="WEB")
                @error ={
                    message: "Parameter missing",
                    status:  400
                }
                raise @error
            end

            @active_app_session = get_active_app_session(params[:person_id], params[:community_id], params[:session_token])

            if @active_app_session.empty? 
                @error ={
                    message: "Session expired. Please logout and login again.",
                    status: 101
                }
                raise @error
            end

            @current_customer = get_user_details(params[:person_id], params[:community_id])
            @current_user = Person.find_by_id(params[:person_id])

            if @current_customer.empty?
                @error ={
                    message: "Session expired. Please logout and login again.",
                    status: 101
                }
                raise @error
            end
            s3uploader = S3Uploader.new 
            @s3_upload_path = s3uploader.url.to_s
            @s3_upload_path.slice!(-1)
            @path = @s3_upload_path + Person.find(params[:person_id]).image.url(:original).to_s
            @response = HashWithIndifferentAccess.new
            
            @response = @current_customer[0].attributes.except("uuid")
            
            puts "image url will be : " , @active_app_session.last.person.image_url
            
            if @active_app_session.last.person.image_url
                
                @response.merge!(:image => @active_app_session.last.person.image_url )
                
                
            else
                @response.merge!(:image => "https://yelodotred.s3-us-west-2.amazonaws.com/images/listing_images/images/974/medium/download.png?1556313353" || @path)
                
            end
            
            notification_count = InboxService.notification_count(params[:person_id],  params[:community_id])
            
            @response.merge!(:session_token => params[:session_token])
            
            @response.merge!(:notification_count => notification_count)
            @response.merge!(:displayed_name => @current_user.displayed_name)
            @response.merge!(:is_posting_allowed => @current_user.is_posting_allowed)
            if params[:device_token].present?
                update ={
                    :refreshed_at => Time.now,
                    :device_type => params[:device_type],
                    :device_token => params[:device_token]
                }
            else
                    update ={
                        :refreshed_at => Time.now,
                        :device_type => params[:device_type]
                    }
            end
            update_active_app_session(params[:person_id], params[:community_id], params[:session_token], update)
            success_msg(@response)
        rescue => e
            show_error!(@error.present? ? @error[:message] : e.message, @error.present? ? @error[:status] : 400)
        end

    end

    #//-------------------------------end-----------------------//








    #//--------------------------check register email---------------------------//
    def check_register_email
        begin
            if !params[:email] || !params[:community_id]
                @error ={
                    message: "Parameter missing",
                    status:  400
                }
                raise @error
            end
            @response = HashWithIndifferentAccess.new
            @email = check_email(params[:email], params[:community_id])
                if !@email.empty?
                    @response = @email[0].as_json
                    @response["email_status"] = CommunityMembership.find_by(person_id: @email[0].person_id)[:status]

                    s3uploader = S3Uploader.new 
                    @s3_upload_path = s3uploader.url.to_s
                    @s3_upload_path.slice!(-1)
                    @temp_path = Person.find(@email[0].person_id).image_url
                    @path = @s3_upload_path + @temp_path

                    if @temp_path

                        @response.merge!(:image => @temp_path)

                    else

                        @response.merge!(:image => "https://yelodotred.s3-us-west-2.amazonaws.com/images/listing_images/images/974/medium/download.png?1556313353" || @path)

                    end


                else  
                    
                    @error ={
                        message: "Email Doesn't Exists",
                        status:  202
                    }
                    raise @error
                                        

                end
                success_msg(@response)
        rescue => e
            show_error!(@error.present? ? @error[:message] : e.message, @error.present? ? @error[:status] : 400)
        end
    end
    
    #//--------------------------------end---------------------------------//




   #-----------------------------customer app setings ----------------------------------- #

   def get_app_settings

    begin
        if !params[:community_id]
            @error ={
                message: "Parameter missing",
                status:  400
            }
            raise @error
        end
        @community =  Community.find(params[:community_id])
        #@community =  Community.find(3)
        file = File.read("app/controllers/api/v1/assets/currency_iso.json")
         
        data = JSON.parse(file)

        @currency_data = data[@community.currency.downcase]

        @community.currency_symbol = @currency_data["symbol"]
        
        if !@community
            @error ={
                message: "No such community found",
                status: 101
            }
            raise @error
    
        else
            @s3_signup_fields = signup_field_setting
            @app_version_message_and_status = @community.app_version_message_and_status(params[:version], params[:device_type])
            render "app_listings/app_settings"
        end

    rescue => e
        show_error!(@error.present? ? @error[:message] : e.message, @error.present? ? @error[:status] : 400)
    end   

   end


   #//----------------------------------end-------------------------------------------------#


    


    #//--------------------------------customer login-----------------------//
    def customer_login
        begin
            if !params[:email] || !params[:password] || !params[:community_id] ||  !params[:device_type] || !params[:device_token] || (params[:device_type] != "ANDROID" && params[:device_type] != "IOS" &&  params[:device_type] !="WEB")
                @error ={
                    message: "Parameter missing",
                    status:  400
                }
                raise @error
            end
            @person = user_login(params[:email], params[:community_id])
            if @person.empty?
                @error ={
                    message: "Invalid email or username",
                    status:  101
                }
                raise @error
            end
            puts "Login person id is:", @person[0].person_id
            @check_pass = Person.find_by_id(@person[0].person_id)
            
            if @check_pass.is_admin?
                if Rails.env.production?
                  @url     ="https://#{APP_CONFIG.auth_api_key}/authenticate_user"
                  @authKey = APP_CONFIG.auth_api_key
                else
                  @url     = "https://#{APP_CONFIG.auth_api_key}/authenticate_user"
                  @authKey = APP_CONFIG.auth_api_key
                end
                uri = URI(@url)
                https = Net::HTTP.new(uri.host, uri.port)
                https.use_ssl = true
                req = Net::HTTP::Post.new(uri.path, {'Content-Type' =>'application/json'});
          
                req.body ={
                  :email     => @check_pass.try(:emails).try(:first).try(:address),
                  :password  => params[:password],
                  :auth_key  => @authKey,
                  :offering  => 2
                }.to_json
          
                res1 = https.request(req)
                puts "Authresponse################# #{res1.body}"
                puts " Request body was ..... #{req.body} " 
                @authenticate = JSON.parse(res1.body)
                if !@authenticate || @authenticate["status"]!=200
                    @error ={
                        message: "Invalid Password",
                        status:  400
                    }
                    raise @error
                end
            else   
                unless @check_pass.valid_password?(params[:password]).present?
                    @error ={
                        message: "Invalid Password",
                        status:  400
                    }
                    raise @error
                end
            end
            @response = @person[0].attributes.except("uuid")
            str = @person[0].person_id + params[:community_id].to_s + Time.now.to_s
            token = Digest::SHA256.hexdigest(str)

            device_token = params[:device_token]
            s3uploader = S3Uploader.new 
            @s3_upload_path = s3uploader.url.to_s
            @s3_upload_path.slice!(-1)
            @path = @s3_upload_path + Person.find(@person[0].person_id).image.url(:original).to_s

            if @check_pass.image_url


                @response.merge!(:image => @check_pass.image_url )


            else
                @response.merge!(:image => "https://yelodotred.s3-us-west-2.amazonaws.com/images/listing_images/images/974/medium/download.png?1556313353" || @path)

            end

            notification_count = InboxService.notification_count(@person[0].person_id,  params[:community_id])

            @response.merge!(:notification_count => notification_count)

            @response.merge!(:session_token => token)

            @response.merge!(:displayed_name => @check_pass.displayed_name)
            
            @response.merge!(:is_posting_allowed => @check_pass.is_posting_allowed)

            TbActiveAppSession.where(device_token: device_token).update_all(device_token: "") if device_token.present?
            TbActiveAppSession.create(person_id: @person[0].person_id, community_id: params[:community_id], 
                session_token: token, device_token: device_token, device_type: params[:device_type], refreshed_at: Time.now)

            success_msg(@response)
        rescue => e
            show_error!(@error.present? ? @error[:message] : e.message, @error.present? ? @error[:status] : 400)
        end
    end


    #//--------------------------------customer change password-----------------------//
    def change_password
        begin
            if !params[:community_id] || !params[:session_token] || !params[:old_password] || !params[:new_password]
                @error ={
                    message: "Parameter missing",
                    status:  400
                }
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
            my_profile = @active_app_session.last.person
            check_password = my_profile.valid_password?(params[:old_password])
            unless check_password.present?
                @error ={
                    message: "Old password is incorrect.",
                    status: 400
                }
                raise @error
            end
            new_pass = my_profile.update(:password => params[:new_password])
            unless new_pass.present?
                @error ={
                    message: "Something went wrong.",
                    status: 400
                }
                raise @error
            end
            success_msg([])
        rescue => e
            show_error!(@error.present? ? @error[:message] : e.message, @error.present? ? @error[:status] : 400)
        end
    end

    #//--------------------------------customer logout-----------------------//
    def logout
        begin
            if !params[:community_id] || !params[:session_token]
                @error ={
                    message: "Parameter missing",
                    status:  400
                }
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

            des_session = @active_app_session.last.destroy
            unless des_session.present?
                @error ={
                    message: "Something went wrong.",
                    status: 400
                }
                raise @error
            end
            success_msg([])
        rescue => e
            show_error!(@error.present? ? @error[:message] : e.message, @error.present? ? @error[:status] : 400)
        end
    end

    #//--------------------------------customer forgot password-----------------------//
    def forgot_password
        begin
            if !params[:community_id] || !params[:email]
                @error ={
                    message: "Parameter missing",
                    status:  400
                }
                raise @error
            end

            customer = Email.where(:community_id => params[:community_id], :address => params[:email]).last.try(:person)
            unless customer.present?
                @error ={
                    message: "No Registered Account with this Email ",
                    status: 400
                }
                raise @error
            end

            puts " the customer is :::: " , customer



            if reset_password_email(customer,params[:email])
                success_msg([],"Mail has been send to your email to reset password.")
            else
                @error ={
                    message: "Something went wrong.",
                    status: 400
                }
                raise @error
            
            end
         
        rescue => e
            show_error!(@error.present? ? @error[:message] : e.message, @error.present? ? @error[:status] : 400)
        end
    end

    #//--------------------------------customer update profile-----------------------//
    def update_profile
        begin
            if !params[:community_id] || !params[:session_token] || (!params[:phone_number] && !params[:given_name] && !params[:family_name])
                @error ={
                    message: "Parameter missing",
                    status:  400
                }
                raise  "Parameter missing"
            end
            
            @active_app_session = TbActiveAppSession.where("community_id= :cid AND session_token = :sid", cid: params[:community_id], sid: params[:session_token])
            
            puts "Active app session is  :  " , @active_app_session
            if @active_app_session.empty? 
                @error ={
                    message: "Session expired. Please logout and login again.",
                    status: 101
                }
                raise @error
            end
            puts "the params are : " , params
            params[:customer] = {} unless params[:customer].present? 
            params[:customer][:given_name] = params[:given_name] if params[:given_name].present?
            puts "ASd"
            params[:customer][:family_name] = params[:family_name] if params[:family_name].present?
            puts "Bsd"
            params[:customer][:phone_number] = params[:phone_number] if params[:phone_number].present?
            puts " last person is : " , @active_app_session.last.id
            puts " last person is : " , @active_app_session.last.person
            puts "customer params are : " , params[:customer]
            @person =  @active_app_session.last.person
             @person.update(person_update_params)
            puts @person.errors.full_messages
           
            unless @person.present?
                @error ={
                    message: "Something went wrong.",
                    status: 400
                }
                raise "No such user exists"
            end
            #image update
            puts " the image check res is : " , params[:image].exclude?("missing.png")
            if params[:image].present?
                if params[:image].exclude?("missing.png")
                @person.picture_from_url(params[:image])              
                end
            end
            main_hsh = HashWithIndifferentAccess.new

            main_hsh[:data] = Person.find_by(id: @active_app_session.last.person.id).image_url
                main_hsh[:status] = 200
                     main_hsh[:message] = "Success"
                     render :json => main_hsh.to_json
         
        rescue => e
            show_error!(@error.present? ? @error[:message] : e.message, @error.present? ? @error[:status] : 400)
        end
    end
    #//------------------------------end--------------------------------//

    def orderDetails

        begin

            if !params[:session_token] || !params[:conversation_id] || !params[:person_id]
                @error ={
                    message: "Parameter missing",
                    status:  400
                }
                raise @error
            end  

            @active_app_session = TbActiveAppSession.where("session_token = :sid AND person_id = :pid",sid: params[:session_token], pid: params[:person_id])

            if @active_app_session.empty? 
                @error ={
                    message: "Session expired. Please logout and login again.",
                    status: 101
                }
                raise @error
            end
            
            @person = Person.find_by(id: params[:person_id])
            
            Conversation.find_by(id: params[:conversation_id]).mark_as_read(params[:person_id])
            @transaction = Transaction.find_by(conversation_id: params[:conversation_id])
            tktask  = TookanTask.find_by(transaction_id: @transaction.id)
            if tktask.present? 

                @deliver_cHarge = tktask[:task_delivery_charges]

            else   

                @deliver_cHarge = ""


            end

            render "app_listings/orderDetails"
            

        rescue => e
            show_error!(@error.present? ? @error[:message] : e.message, @error.present? ? @error[:status] : 400)
        end

    end

    def sendMessage

        begin


            if !params[:session_token] || !params[:conversation_id] || !params[:content] || !params[:sender_id]
                @error ={
                    message: "Parameter missing",
                    status:  400
                }
                raise @error
            end  

            @active_app_session = TbActiveAppSession.where("session_token = :sid AND person_id = :pid",sid: params[:session_token], pid: params[:sender_id])

            if @active_app_session.empty? 
                @error ={
                    message: "Session expired. Please logout and login again.",
                    status: 101
                }
                raise @error
            end

            message_params = {
                :conversation_id => params[:conversation_id],
                :content => params[:content],
                :sender_id => params[:sender_id]

            }
         
            @message = Message.new(message_params)
            if @message.save
                render "app_listings/message"

            else
                @error ={
                    message: "Invalid Action",
                    status:  201
                }
                raise @error


            end
            

        rescue => e
            show_error!(@error.present? ? @error[:message] : e.message, @error.present? ? @error[:status] : 400)
        end

    end

    def msg_detail
        begin
            if !params[:session_token] || !params[:transaction_id]
                @error ={
                    message: "Parameter missing",
                    status:  400
                }
                raise @error
            end  
            @active_app_session = TbActiveAppSession.where(:session_token => params[:session_token])
            if @active_app_session.empty? 
                @error ={
                    message: "Session expired. Please logout and login again.",
                    status: 101
                }
                raise @error
            end
            @current_community = @active_app_session.last.community
            @transaction = @active_app_session.last.community.transactions.find_by_id(params[:transaction_id])
            @conversation = @transaction.conversation
            @message = TransactionViewUtils.merge_messages_and_transitions(TransactionViewUtils.conversation_messages(@conversation.messages, @current_community.name_display_type), TransactionViewUtils.transition_messages(@transaction, @conversation, @current_community.name_display_type)).last
            main_hsh = HashWithIndifferentAccess.new
            hsh = HashWithIndifferentAccess.new
            hsh[:id] = @conversation.id
            hsh[:last_message_at] = @message[:created_at]
            hsh[:starting_page] = "payment"
            msg_hsh = HashWithIndifferentAccess.new
            msg_hsh[:id] = ""
            msg_hsh[:content] = @message[:content]
            hsh[:message] = msg_hsh
            other_party_hsh = HashWithIndifferentAccess.new
            other_party_hsh[:id] = @message[:sender].id
            other_party_hsh[:image_url] = @message[:sender].image_url
            other_party_hsh[:given_name] = @message[:sender].given_name
            hsh[:other_party] = other_party_hsh
            main_hsh[:data] = hsh
            main_hsh[:status] = 200
            main_hsh[:message] = "Success"
            render :json => main_hsh.to_json
        rescue => e
            show_error!(@error.present? ? @error[:message] : e.message, @error.present? ? @error[:status] : 400)
        end
    end

    def getMessageTrail

        begin

            if !params[:session_token] || !params[:conversation_id]
                @error ={
                    message: "Parameter missing",
                    status:  400
                }
                raise "Parameter missing"
            end  

            @active_app_session = TbActiveAppSession.where("session_token = :sid",sid: params[:session_token])

            if @active_app_session.empty? 
                @error ={
                    message: "Session expired. Please logout and login again.",
                    status: 101
                }
                raise @error
            end
        @current_community = @active_app_session.last.community
        @conversation = Conversation.find(params[:conversation_id])
        @transaction = @conversation.tx
        puts "message trail is called..."
        date = Time.new 
        params[:page] = 1 unless params[:page].present?
        # @messages = Conversation.find(params[:conversation_id]).messages.order("id desc").paginate(page: params[:page].to_i, per_page: 20).reverse
        start_value = ((params[:page].to_i-1)*20)
        end_value = (params[:page].to_i*20)-1
        @messages = TransactionViewUtils.merge_messages_and_transitions(TransactionViewUtils.conversation_messages(@conversation.messages, @current_community.name_display_type),TransactionViewUtils.transition_messages(@transaction, @conversation, @current_community.name_display_type))[start_value..end_value]
        puts "the messagesa are : " , @messages
        render "app_listings/messageTrail"

        rescue => e
            show_error!(@error.present? ? @error[:message] : e.message, @error.present? ? @error[:status] : 400)
        end


    end

    def getDeliveryCharge

        begin

            if !params[:session_token] || !params[:delivery_latitude] ||  !params[:delivery_longitude] ||  !params[:pickup_latitude] || !params[:pickup_longitude]

                

                puts " Paramater is missing .... " 
                @error ={
                    message: "Parameter missing",
                    status:  400
                }
                raise @error

    
            end

                @url = "https://api.tookanapp.com/v2/get_fare_estimate"
                uri = URI(@url)
                https = Net::HTTP.new(uri.host, uri.port)
                https.use_ssl = true
                req = Net::HTTP::Post.new(uri.path, {'Content-Type' =>'application/json'})
                req.body = { 
                  :api_key => "",
                  :template_name => 'Order', 
                  :pickup_latitude => params[:pickup_latitude],
                  :pickup_longitude => params[:pickup_longitude],
                  :delivery_latitude => params[:delivery_latitude],
                  :delivery_longitude => params[:delivery_longitude]
                  }; 

                  main_hsh = HashWithIndifferentAccess.new
    
                  begin
                    req.body = req.body.to_json
                    puts " the request body is : " , req.body
                    
                    res = https.request(req)
                    hsh = HashWithIndifferentAccess.new
                    res = JSON.parse(res.body) 
                    puts "the  response body is : "  , res

                    hsh[:delivery_charge] = res["data"]["estimated_fare"]
                    main_hsh[:data] = hsh
                    main_hsh[:status] = res["status"]
                    main_hsh[:message] = res["message"]
                    render :json => main_hsh.to_json

                   
                  rescue => e
                    show_error!(@error.present? ? @error[:message] : e.message, @error.present? ? @error[:status] : 400)
                end
                
                

            
        rescue => e
            show_error!(@error.present? ? @error[:message] : e.message, @error.present? ? @error[:status] : 400)
        end

end


    def getMessages
        begin
            if !params[:session_token] || !params[:person_id]
                @error ={
                    message: "Parameter missing",
                    status:  400
                }
                raise "Parameter missing"
            end   
            @my_id = params[:person_id]
        
            puts "get Messages is called .... "

            @active_app_session = TbActiveAppSession.where("session_token = :sid AND person_id = :pid",sid: params[:session_token], pid: params[:person_id])

            if @active_app_session.empty? 
                @error ={
                    message: "Session expired. Please logout and login again.",
                    status: 101
                }
                raise @error
            end


        @person = Person.find_by(id: @my_id)
        @current_community = @person.community
        # debugger
        limit = params[:limit].to_i || 0
        offset = params[:offset].to_i || 0
        @participations = InboxService.inbox_data(@person.id, @person.community_id, limit, offset, nil)
        # if limit == 0 && offset == 0
        #     @participations = Person.find_by(id: params[:person_id]).participations.order(:updated_at).reverse_order

        # elsif limit > 0 && offset > 0
        #     @participations = Person.find_by(id: params[:person_id]).participations.order(:updated_at).reverse_order.limit(limit).offset(offset)

        # elsif limit > 0 && offset == 0
        #     @participations = Person.find_by(id: params[:person_id]).participations.order(:updated_at).reverse_order.limit(limit)
            
        # end

        
        # @Messages = Person.find_by(id: params[:person_id]).messages
        render "app_listings/messages"
        # render :json => Conversation.all_conversation_hsh(@participations)

        rescue => e
            show_error!(@error.present? ? @error[:message] : e.message, @error.present? ? @error[:status] : 400)
        end

    end

    def generate_token
      begin
        if !params[:session_token] || !params[:listing_id]
            @error ={
                message: "Parameter missing",
                status:  400
            }
            raise @error
        end   
        @active_app_session = TbActiveAppSession.where("session_token = :sid",sid: params[:session_token])

        if @active_app_session.empty? 
            @error ={
                message: "Session expired. Please logout and login again.",
                status: 101
            }
            raise @error
        end
        auth_token = UserService::API::AuthTokens.create_login_token(@active_app_session.last.person_id)
        listing_data = Listing.find(params[:listing_id])        
        address = URI.encode(listing_data.location.address)
            google_address = URI.encode(listing_data.location.google_address)
            lat = listing_data.location.latitude
            lng = listing_data.location.longitude
            utype = listing_data.unit_type.to_s
            sa_name = URI.encode(params[:shipping_address_name].presence || "" )
            sa_street1 = URI.encode(params[:shipping_address_street1].presence || "" )
            sa_street2 = URI.encode(params[:shipping_address_street2].presence || "" )
            sa_city = URI.encode(params[:shipping_address_city].presence || "" )
            # my_locale = params[:locale].presence || @current_community.default_locale
            hsh = HashWithIndifferentAccess.new
            order_request = OrderRequestDetail.create(listing_id: params[:listing_id], app_session_token: params[:session_token], order_detail: params.to_json)
            hsh[:tranx_link] = "en/app_pages/transaction?utf8=%E2%9C%93&order_request_id=#{order_request.id}&app_session_token=#{params[:session_token]}&auth=#{auth_token[:token]}"

            # hsh[:tranx_link] = "en/app_pages/transaction?utf8=%E2%9C%93&payment_type=#{params[:payment_type]}&start_on=#{params[:start_on]}&end_on=#{params[:end_on]}&listing_id=#{params[:listing_id]}&unit_type=#{utype}&quantity=#{params[:quantity]}&per_hour=#{params[:per_hour]}&start_time=#{params[:start_time]}&end_time=#{params[:end_time]}&delivery=#{params[:delivery]}&sa_name=#{sa_name}&sa_street1=#{sa_street1}&sa_street2=#{sa_street2}&sa_postal_code=#{params[:shipping_address_postal_code]}&sa_city=#{sa_city}&sa_country_code=#{params[:shipping_address_country_code]}&sa_state_or_province=#{params[:shipping_address_state_or_province]}&contract_agreed=#{params[:contract_agreed]}&app_session_token=#{params[:session_token]}&auth=#{auth_token[:token]}"
            success_msg(hsh)
      rescue => e
        show_error!(@error.present? ? @error[:message] : e.message, @error.present? ? @error[:status] : 400)
      end
    end

    def app_payment_callback
        hsh = HashWithIndifferentAccess.new
        hsh[:status] = params[:payment_error_callback]
        hsh[:message] = request.flash[:error].presence || params[:error]
        render :json => hsh.to_json
    end

    def app_payment_success_error
        hsh = HashWithIndifferentAccess.new
        hsh[:status] = 200
        hsh[:message] = request.flash[:error].presence || params[:error]
        render :json => hsh.to_json
    end

    def app_error_callback
        hsh = HashWithIndifferentAccess.new
        hsh[:status] = params[:payment_error_callback]
        hsh[:message] = request.flash[:error].presence || params[:error]
        render :json => hsh.to_json
    end

    def accept_reject_payment
      begin
        if !params[:session_token] || !params[:id] || !params[:status]
            @error ={
                message: "Parameter missing",
                status:  400
            }
            raise @error
        end
        @active_app_session = TbActiveAppSession.where(session_token: params[:session_token])
        if @active_app_session.empty? 
            @error ={
                message: "Session expired. Please logout and login again.",
                status: 101
            }
            raise @error
        end
        @current_community = @active_app_session.last.community
        @current_user = @active_app_session.last.person
        FeatureFlagHelper.init(community_id: @current_community.id, user_id: @current_user&.id, request: request,  is_admin: Maybe(@current_user).is_admin?.or_else(false), is_marketplace_admin: Maybe(@current_user).is_marketplace_admin?(@current_community).or_else(false))
        tx_id = @current_community.conversations.find(params[:id]).tx.id
        message = params[:message]
        status = params[:status].to_sym
        sender_id = @active_app_session.last.person_id
        @current_community = @active_app_session.last.community
        tx = @current_community.transactions.find(tx_id)
        
        if tx.current_state != 'preauthorized'
            @error ={
                message: "Current State is not preauthorized.",
                status:  400
            }
            raise @error
        end

        res = accept_or_reject_tx(@current_community.id, tx_id, status, message, sender_id)
        p res
        flash = HashWithIndifferentAccess.new
        if res[:success]
          flash[:notice] = success_msg1(res[:flow])
    
          record_event(
            flash,
            status == :paid ? "PreauthorizedTransactionAccepted" : "PreauthorizedTransactionRejected",
            { listing_id: tx.listing_id,
              listing_uuid: UUIDUtils.parse_raw(tx.listing_uuid).to_s,
              transaction_id: tx.id })
    
            # redirect_to person_transaction_path(person_id: sender_id, id: tx_id)
            # success_msg( success_msg1(res[:flow]) )
            # redirect_to api_v1_app_payment_callback_path(:status => 200, :message => success_msg1(res[:flow]))
        else
        #   flash[:error] = error_msg(res[:flow], tx)
        #   redirect_to accept_preauthorized_person_message_path(person_id: sender_id , id: tx_id)
            @error ={
                message: error_msg(res[:flow], tx),
                status:  400
            }
            raise @error
        end
        updated_tx = @current_community.transactions.find(tx_id)
        updated_tx.accept_reject_payment_notification(status)
        response = {
            conversation_statuses: updated_tx.get_conversation_statuses(@current_user),
            conversation_btns: updated_tx.get_conversation_btns(@current_user),
            current_state: updated_tx.current_state
        }
        success_msg(response)
      rescue => e
        p e
        show_error!(@error.present? ? @error[:message] : e.message, @error.present? ? @error[:status] : 400)
      end
    end

    #status => confirmed, canceled
    def mark_as_complete_dispute
        begin
            if !params[:session_token] || !params[:id] || !params[:status] || !params[:feedback]
                @error ={
                    message: "Parameter missing",
                    status:  400
                }
                raise @error
            end
            @active_app_session = TbActiveAppSession.where(session_token: params[:session_token])
            if @active_app_session.empty? 
                @error ={
                    message: "Session expired. Please logout and login again.",
                    status: 101
                }
                raise @error
            end
            @current_user = @active_app_session.last.person
            @current_community = @active_app_session.last.community
            status = params[:status].to_sym
            @listing_transaction = @current_community.conversations.find(params[:id]).tx
            if !TransactionService::StateMachine.can_transition_to?(@listing_transaction.id, status)
                @error ={
                    message: "Something went wrong",
                    status: 400
                }
                raise @error
            end
            transaction = complete_or_cancel_tx(@current_community.id, @listing_transaction.id, status, "", @current_user.id)
            confirmation = ConfirmConversation.new(@listing_transaction, @current_user, @current_community)
            has_given_feedback = !params[:feedback].to_i.zero?
            confirmation.update_participation(has_given_feedback)
            if params[:feedback].to_i == 1 #give feedback
                @testimonial = @listing_transaction.testimonials.build(receiver_id: @listing_transaction.other_party(@current_user).id, author_id: @current_user.id, text: params[:text], grade: params[:grade])
                if @testimonial.save
                    Delayed::Job.enqueue(TestimonialGivenJob.new(@testimonial.id, @current_community.id))
                end
            else #skip feedback
                is_author = @listing_transaction.author == @current_user
                if is_author
                    @listing_transaction.update_attributes(author_skipped_feedback: true)
                else
                    @listing_transaction.update_attributes(starter_skipped_feedback: true)
                end
            end
            updated_tx = @current_community.transactions.find_by_id(@listing_transaction.id)
            if @listing_transaction.try(:conversation).try(:participations).present?
                @listing_transaction.conversation.participations.find_by_person_id(@current_user.id).update_attribute(:is_read, true) if @listing_transaction.try(:conversation).try(:participations).find_by_person_id(@current_user.id).present?
            end
            updated_tx.complete_cancel_payment_notification(status)
            response = {
                conversation_statuses: updated_tx.get_conversation_statuses(@current_user),
                conversation_btns: updated_tx.get_conversation_btns(@current_user),
                current_state: updated_tx.current_state
            }
            success_msg(response)
        rescue => e
            p e
            show_error!(@error.present? ? @error[:message] : e.message, @error.present? ? @error[:status] : 400)
        end
    end

    #feedback, grade, text
    def feedback
        begin
            if !params[:session_token] || !params[:id] || !params[:feedback]
                @error ={
                    message: "Parameter missing",
                    status:  400
                }
                raise @error
            end
            @active_app_session = TbActiveAppSession.where(session_token: params[:session_token])
            if @active_app_session.empty? 
                @error ={
                    message: "Session expired. Please logout and login again.",
                    status: 101
                }
                raise @error
            end
            @current_user = @active_app_session.last.person
            @current_community = @active_app_session.last.community
            @listing_transaction = @current_community.conversations.find(params[:id]).tx
            if params[:feedback].to_i == 1 #give feedback
                @testimonial = @listing_transaction.testimonials.build(receiver_id: @listing_transaction.other_party(@current_user).id, author_id: @current_user.id, text: params[:text], grade: params[:grade])
                if @testimonial.save
                    Delayed::Job.enqueue(TestimonialGivenJob.new(@testimonial.id, @current_community.id))
                end
            else #skip feedback
                is_author = @listing_transaction.author == @current_user
                if is_author
                  @listing_transaction.update_attributes(author_skipped_feedback: true)
                else
                  @listing_transaction.update_attributes(starter_skipped_feedback: true)
                end
            end
            updated_tx = @current_community.transactions.find_by_id(@listing_transaction.id)
            response = {
                conversation_statuses: updated_tx.get_conversation_statuses(@current_user),
                conversation_btns: updated_tx.get_conversation_btns(@current_user),
                current_state: updated_tx.current_state
            }
            success_msg(response)
        rescue => e
            p e
            show_error!(@error.present? ? @error[:message] : e.message, @error.present? ? @error[:status] : 400)
        end
    end

  private

    def complete_or_cancel_tx(community_id, tx_id, status, msg, sender_id)
        if status == :confirmed
          TransactionService::Transaction.complete(community_id: community_id, transaction_id: tx_id, message: msg, sender_id: sender_id)
        else
          TransactionService::Transaction.cancel(community_id: community_id, transaction_id: tx_id, message: msg, sender_id: sender_id)
        end
    end
    
    def accept_or_reject_tx(community_id, tx_id, status, message, sender_id)
      if (status == :paid)
        accept_tx(community_id, tx_id, message, sender_id)
      elsif (status == :rejected)
        reject_tx(community_id, tx_id, message, sender_id)
      else
        {flow: :unknown, success: false}
      end
    end
  
    def accept_tx(community_id, tx_id, message, sender_id)
      TransactionService::Transaction.complete_preauthorization(community_id: community_id,
                                                                transaction_id: tx_id,
                                                                message: message,
                                                                sender_id: sender_id)
        .maybe()
        .map { |_| {flow: :accept, success: true}}
        .or_else({flow: :accept, success: false})
    end
  
    def reject_tx(community_id, tx_id, message, sender_id)
      TransactionService::Transaction.reject(community_id: community_id,
                                             transaction_id: tx_id,
                                             message: message,
                                             sender_id: sender_id)
        .maybe()
        .map { |_| {flow: :reject, success: true}}
        .or_else({flow: :reject, success: false})
    end
  
    def success_msg1(flow)
      if flow == :accept
        return "Request Accepted"
        # t("layouts.notifications.request_accepted")
    elsif flow == :reject
        return "Request Rejected"
        # t("layouts.notifications.request_rejected")
      end
    end
  
    def error_msg(flow, tx)
      payment_gateway = tx.payment_gateway
      if flow == :accept
        if payment_gateway == :paypal
          return "Accept Paypal Authorization error."
          #   t("error_messages.paypal.accept_authorization_error")
        elsif payment_gateway == :stripe
            return "Accept Stripe Authorization error."
            #   t("error_messages.stripe.accept_authorization_error")
        end
    elsif flow == :reject
        if payment_gateway == :paypal
            return "Reject Paypal  Authorization error."
            # t("error_messages.paypal.reject_authorization_error")
        elsif payment_gateway == :stripe
            return "Reject Stripe  Authorization error."
        #   t("error_messages.stripe.reject_authorization_error")
        end
      end
    end
  
  
    def people_params
        params.require(:customer).permit(:community_id, :given_name, :family_name,  :password, :phone_number, :email, :username, :locale, custom_field_values_attributes: [:id, :type, :custom_field_id, :person_id, :text_value, :numeric_value, :'date_value(1i)', :'date_value(2i)', :'date_value(3i)', :file_upload_value, selected_option_ids: []])
    end

    def person_update_params

        params.require(:customer).except(:session_token,:image).permit(:given_name,:family_name,:phone_number, :community_id, custom_field_values_attributes: [:id, :type, :custom_field_id, :person_id, :text_value, :numeric_value, :'date_value(1i)', :'date_value(2i)', :'date_value(3i)', :file_upload_value, selected_option_ids: []])
    end
    
    def check_username_email_avaialabilty(username, email, cid)
        Person.joins("LEFT JOIN communities ON people.community_id = communities.id 
            LEFT JOIN emails ON emails.person_id = people.id").
        where("communities.id = :cid AND (emails.address = :em OR people.username= :user)", em:  email, user: username, cid: cid)
    end

    def find_community_by_id(cid)
        Community.find(cid)
    end

    def get_user_details(person_id, cummunity_id)
        Person.select("pe.community_id,
            pe.id AS person_id,
            pe.is_admin,
            pe.uuid,
            pe.locale,
            pe.preferences,
            pe.active_days_count,
            pe.username,
            pe.sign_in_count,
            pe.given_name,
            pe.family_name,
            pe.display_name,
            pe.phone_number,
            pe.facebook_id,
            pe.authentication_token,
            pe.deal_id,
            cu.ident,
            cu.domain,
            cu.use_domain,
            cu.settings,
            cu.allowed_emails,
            cu.country,
            cu.slogan,
            em.address AS email").joins("LEFT JOIN communities cu ON pe.community_id = cu.id
            LEFT JOIN emails em ON em.person_id = pe.id").from("people pe").
            where("pe.community_id = :cid AND pe.id= :pid", cid: cummunity_id, pid: person_id)
    end

    def get_active_app_session(person_id, community_id, token)
        TbActiveAppSession.where("person_id = :pid AND community_id= :cid AND session_token = :sid", pid: person_id, cid: community_id, sid: token)
    end

    def update_active_app_session(person_id, community_id, token, update_hash)
        TbActiveAppSession.where("person_id = :pid AND community_id= :cid AND session_token = :sid", pid: person_id, cid: community_id, sid: token).update_all(update_hash)
    end

    def check_email(email, community_id)
        Email.select("emails.address AS email,emails.community_id, emails.person_id, people.given_name").joins("LEFT JOIN people ON emails.person_id = people.id").where("emails.community_id = :cid AND (people.username = :eid OR emails.address = :eid)", eid: email, cid: community_id)
    end

    def reset_password_email(person,email)
      community = Community.find(person.community_id)
      begin

        token = person.reset_password_token_if_needed
        puts "the tokan is : " , token
        #UserMailer::Mandrill.reset_password(params[:email], token, @current_community, person , false)
        MailCarrier.deliver_now(PersonMailer.reset_password_instructions(person, email, token, community))

        return true

    rescue => e 

        puts " the exceptions is : " , e

        return false

    end

    end

    def user_login(email,  community_id)
        Person.select("pe.community_id,
            pe.id AS person_id,
            pe.is_admin,
            pe.uuid,
            pe.locale,
            pe.preferences,
            pe.active_days_count,
            pe.username,
            pe.sign_in_count,
            pe.given_name,
            pe.family_name,
            pe.display_name,
            pe.phone_number,
            pe.facebook_id,
            pe.authentication_token,
            pe.deal_id,
            cu.ident,
            cu.domain,
            cu.use_domain,
            cu.settings,
            cu.allowed_emails,
            cu.country,
            cu.slogan,
            em.address AS email").joins("LEFT JOIN communities cu ON pe.community_id = cu.id
            LEFT JOIN emails em ON em.person_id = pe.id").from("people pe").
            where("pe.community_id =:cid AND (pe.username = :uid OR em.address = :uid) ", cid: community_id, uid: email )
    end

    def signup_field_setting
        s3 =  S3Uploader.new
        s3_signup_fields = s3.signup_page_fields
        signup_fields =  HashWithIndifferentAccess.new(s3_signup_fields)
        signup_fields[:expiration] = 20.hours.from_now
        signup_fields[:aws_secret_access_key] = APP_CONFIG.aws_secret_access_key
        signup_fields[:aws_access_key_id] = APP_CONFIG.aws_access_key_id
        signup_fields[:bucket_url] = s3.url
        signup_fields[:bucket_name] = APP_CONFIG.s3_upload_bucket_name
        return signup_fields
    end

end
