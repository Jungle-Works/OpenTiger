require 'rest_client'

class SessionsController < ApplicationController

  skip_before_action :cannot_access_if_banned, :only => [ :destroy, :confirmation_pending ]
  skip_before_action :cannot_access_without_confirmation, :only => [ :destroy, :confirmation_pending ]
  skip_before_action :ensure_consent_given, only: [ :destroy, :confirmation_pending ]
  skip_before_action :ensure_user_belongs_to_community, :only => [ :destroy, :confirmation_pending ]

  # For security purposes, Devise just authenticates an user
  # from the params hash if we explicitly allow it to. That's
  # why we need to call the before filter below.
  before_action :allow_params_authentication!, :only => [:create,:new]

  def new
    if logged_in?
      redirect_to admin_path
    end
    puts "new calledd..."
    if params[:return_to].present?
      session[:return_to] = params[:return_to]
    end
    @selected_tribe_navi_tab = "members"
    omniauth = session["devise.omniauth_data"]
    @facebook_merge = omniauth.present?
    if @facebook_merge
      @facebook_email = omniauth["email"]
      @facebook_name = "#{omniauth["given_name"]} #{omniauth["family_name"]}"
    end
    render action: get_partial_path
  end

  def create
    session[:form_login] = params[:person][:login]
    session[:form_password] = params[:person][:password]

    puts " the password is : " , params[:person][:password]
    # Start a session with Devise

      # In case of failure, set the message already here and
     # clear it afterwards, if authentication worked.


    flash.now[:error] = t("layouts.notifications.login_failed")


    # Since the authentication happens in the rack layer,
    # we need to tell Devise to call the action "sessions#new"
    # in case something goes bad.

    person = authenticate_person!(:recall => "sessions#new")

    @current_user = person

    puts "create called .... "
    if @current_user.is_admin?
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
        :email     => Email.find_by(person_id: @current_user.id)[:address],
        :password  => params[:person][:password],
        :auth_key  => @authKey,
        :offering  => 2
      }.to_json

      res1 = https.request(req)
      puts "Authresponse################# #{res1.body}"
      puts " Request body was ..... #{req.body} " 
      @authenticate = JSON.parse(res1.body)
      if !@authenticate || @authenticate["status"]!=200
        #flash[:error] = t("layouts.notifications.login_failed")
        sign_out
        flash[:error] = t("layouts.notifications.login_failed")
      
        return redirect_to login_path
      end

    else
      if person.valid_password?(params[:person][:password]) == false

       sign_out
       flash[:error] = t("layouts.notifications.login_failed")
   
       return redirect_to login_path
       
     end
    end

    flash[:error] = nil

    sign_in @current_user

    setup_intercom_user

    session[:form_login] = nil

    unless @current_user.is_admin? || terms_accepted?(@current_user, @current_community)
      sign_out @current_user
      session[:temp_cookie] = "pending acceptance of new terms"
      session[:temp_person_id] =  @current_user.id
      session[:temp_community_id] = @current_community.id
      session[:consent_changed] = true if @current_user
      redirect_to terms_path and return
    end

    login_successful = t("layouts.notifications.login_successful", person_name: view_context.link_to(PersonViewUtils.person_display_name_for_type(@current_user, "first_name_only"), person_path(@current_user)))
    visit_admin = t('layouts.notifications.visit_admin', link: view_context.link_to(t('layouts.notifications.visit_admin_link'), admin_details_edit_path))
    flash[:notice] = "#{login_successful}#{@current_user.has_admin_rights?(@current_community) ? " #{visit_admin}" : ''}".html_safe
    if session[:return_to]
      redirect_to session[:return_to]
      session[:return_to] = nil
    elsif session[:return_to_content]
      redirect_to session[:return_to_content]
      session[:return_to_content] = nil
    else
      redirect_to search_path
    end
  end

  def destroy
    logged_out_user = @current_user
    sign_out

    # Admin Intercom shutdown
    IntercomHelper::ShutdownHelper.intercom_shutdown(session, cookies, request.host_with_port)

    flash[:notice] = t("layouts.notifications.logout_successful")
    mark_logged_out(flash, logged_out_user)
    redirect_to landing_page_path
  end

  def index
    redirect_to login_path
  end

  def forgot_password
    render :action => "flex_theme/flex_password_forgotten"
  end

  def login_via_access_token
    begin
      @error = nil
      if !request.params["access_token"].present?
        @error = "Please provide the access token .. Example rentals.yelo.red/login_v2?access_token=ajsldkj99809"      
        raise @error      
      end
      access_token = request.params["access_token"]
      if Rails.env.production?
        @url     ="https://#{APP_CONFIG.auth_api_key}/get_user_detail"
        @authKey = APP_CONFIG.auth_api_key
      else
        @url     = "https://#{APP_CONFIG.auth_api_key}/get_user_detail"
        @authKey = APP_CONFIG.auth_api_key
      end
        uri = URI(@url)
        https = Net::HTTP.new(uri.host, uri.port)
        https.use_ssl = true
        req = Net::HTTP::Post.new(uri.path, {'Content-Type' =>'application/json'})
        req.body = { 
          :field_names => "*",
          :access_token => access_token, 
          :auth_key => @authKey,
          :offering => 2
          }; 
        req.body = req.body.to_json
        res1 = https.request(req)
        @authBody = JSON.parse(res1.body)
        if @authBody["status"] != 200
          @error = "Invalid access token "
          raise @error
        end   
        @auth_user_all_detail = @authBody["data"][0]
        @email = Email.find_by(address: @auth_user_all_detail["email"])
        if !@email.present? 
          @error = "Email not found here !!" 
          raise @error     
        end 
        if !@email.person  
          @error = "No associated person found !!" 
          raise @error  
        end  
        if !@email.person.is_admin?
          @error = "The Person is not the admin !!"
          raise @error
        end    
        @current_community = @email.person.community
        request.env[:community_id] = @current_community.id
        setup_logger!(marketplace_id: @current_community.id, marketplace_ident: @current_community.ident)
        @current_user = @email.person
        sign_in @current_user
        setup_intercom_user
        login_successful = t("layouts.notifications.login_successful", person_name: view_context.link_to(PersonViewUtils.person_display_name_for_type(@current_user, "first_name_only"), person_path(@current_user)))
        visit_admin = t('layouts.notifications.visit_admin', link: view_context.link_to(t('layouts.notifications.visit_admin_link'), admin_details_edit_path))
        flash[:notice] = "#{login_successful}#{@current_user.has_admin_rights?(@current_community) ? " #{visit_admin}" : ''}".html_safe
        redirect_to search_path
    rescue => e   
      puts " the error is : " , e
      render action: :login_via_access_token, locals: {
        error: e
      }
    end  
  end


  def request_new_password
    person =
      Person
      .joins("LEFT OUTER JOIN emails ON emails.person_id = people.id")
      .where("emails.address = :email AND people.community_id = :cid", email: params[:email], cid: @current_community.id)
      .first
    if person
      if person.is_admin?
        @url     = "http://#{APP_CONFIG.auth_api_key}:3015/forgot_password"
        @authKey = APP_CONFIG.auth_api_key
        @httpSsl = false
        @nodeUrl = "https://rental-api-3004.yelo.red/reset_password?token="

        if Rails.env.production?
          @url      ="https://#{APP_CONFIG.auth_api_key}/forgot_password"
          @authKey  = APP_CONFIG.auth_api_key
          @httpSsl = true
          @nodeUrl  = "https://rentals-api.yelo.red/reset_password?token="
        end
        uri = URI(@url)
        https = Net::HTTP.new(uri.host, uri.port)
        https.use_ssl = @httpSsl
        req = Net::HTTP::Post.new(uri.path, {'Content-Type' =>'application/json'});
        req.body ={
          :email      => params[:email],
          :auth_key   => @authKey ,
          :offering   => 2
        }.to_json
        res1 = https.request(req)
        puts "Authresponse################# #{res1.body} #{req.body} #{uri} #{@httpSsl}" 
        @authenticate = JSON.parse(res1.body)
       if @authenticate && @authenticate["status"] == 200
         flash[:notice] = t("layouts.notifications.password_recovery_sent")
         link = @nodeUrl+ @authenticate["data"]["token"]+'&domain='+"https://" +@current_community["domain"]+"&user_id="+@authenticate["data"]["user_id"].to_s
        UserMailer::Mandrill.reset_password(params[:email], link, @current_community, person,true)
       else
         flash[:error] = t("layouts.notifications.email_not_found")
        end
       return redirect_to login_path
      end
      token = person.reset_password_token_if_needed
      #UserMailer::Mandrill.reset_password(params[:email], token, @current_community, person , false)
      MailCarrier.deliver_later(PersonMailer.reset_password_instructions(person, params[:email], token, @current_community))
      flash[:notice] = t("layouts.notifications.password_recovery_sent")
    else
      flash[:error] = t("layouts.notifications.email_not_found")
    end

    redirect_to login_path
  end

  def passthru
    render status: 404, plain: "Not found. Authentication passthru."
  end
  private

  def terms_accepted?(user, community)
    user && community.consent.eql?(user.consent)
  end

  def get_origin_locale(request, available_locales)
    locale_string ||= URLUtils.extract_locale_from_url(request.env['omniauth.origin']) if request.env['omniauth.origin']
    if locale_string && available_locales.include?(locale_string)
      locale_string
    end
  end

  def get_partial_path
    case @current_theme_identifier
    when "flex-theme"
      partial_path = "flex_theme/login"
    else
      partial_path = "new"
    end

  end

end
