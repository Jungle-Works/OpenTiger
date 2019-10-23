require 'csv'
require 'securerandom'

class Admin::CommunityMembershipsController < Admin::AdminBaseController
  before_action :set_selected_left_navi_link
  before_action :set_service

  def index
    respond_to do |format|
      format.html {}
      format.csv do
        marketplace_name = if @current_community.use_domain
          @current_community.domain
        else
          @current_community.ident
        end

        self.response.headers["Content-Type"] ||= 'text/csv'
        self.response.headers["Content-Disposition"] = "attachment; filename=#{marketplace_name}-users-#{Date.today}.csv"
        self.response.headers["Content-Transfer-Encoding"] = "binary"
        self.response.headers["Last-Modified"] = Time.now.ctime.to_s

        self.response_body = @service.memberships_csv
      end
    end
  end

  def ban
    if @service.membership_current_user?
      flash[:error] = t("admin.communities.manage_members.ban_me_error")
      return redirect_to admin_community_community_memberships_path(@current_community)
    end

    membership = @service.ban

    if request.xhr?
      render json: {status: membership.status}
    else
      redirect_to admin_community_community_memberships_path(@current_community)
    end
  end

  def unban
    membership = @service.unban
    if request.xhr?
      render json: {status: membership.status}
    else
      redirect_to admin_community_community_memberships_path(@current_community)
    end
  end

  def promote_admin
    if @service.removes_itself?
      render body: nil, status: 405
    else
      @service.promote_admin
      render body: nil, status: 200
    end
  end

  def build_devise_resource_from_person(person_params)
    #remove terms part which confuses Devise

    person_params.delete(:terms)
    person_params.delete(:admin_emails_consent)
    # This part is copied from Devise's regstration_controller#create
    build_resource(person_params)
    resource
    
  end

  def new_person(initial_params, current_community)
    initial_params[:person][:locale] =  params[:locale] || APP_CONFIG.default_locale
    initial_params[:person][:test_group_number] = 1 + rand(4)
    initial_params[:person][:community_id] = current_community.id
    user_email = params[:person][:email]
    params = person_create_params(initial_params)
    admin_emails_consent = params[:admin_emails_consent]
    params.delete(:email)
    person = Person.create!(params) 
    email = Email.new(:person => person, :address => user_email.downcase, :send_notifications => true, community_id: current_community.id)
    #person = build_devise_resource_from_person(params)
    person.emails << email
    person.inherit_settings_from(current_community)
    #person.deal_id = initial_params[:person][:deal_id]
    person.save
    person.set_default_preferences
    person.preferences["email_from_admins"] = (admin_emails_consent == "on")
    person.save
    [person, email]
  end
  def generate_username(given_name, family_name, community_id)
    base = (given_name.strip + (family_name.empty? ? '' : family_name.strip[0])).to_url.delete('-')[0...18]
    generate_username_from_base(base, community_id)
  end
  def generate_username_from_base(base, community_id)
    taken = fetch_taken_usernames(base, community_id)
    reserved = Person.username_blacklist.concat(taken)
    gen_free_name(base, reserved)
  end
  def fetch_taken_usernames(base, community_id)
    Person.where("username LIKE :prefix AND community_id = :community_id",
                 prefix: "#{base}%", community_id: community_id).pluck(:username)
  end
  def gen_free_name(base, reserved)
    (1..100000).reduce([base, ""]) do |(base_name, postfix), next_postfix|
      return (base_name + postfix) unless reserved.include?(base_name + postfix) || (base_name + postfix).length < 3
      [base_name, next_postfix.to_s]
    end
  end

  def person_create_params(params)
    result = params.require(:person).slice(
        :given_name,
        :family_name,
        :display_name,
        :street_address,
        :phone_number,
        :image,
        :description,
        :location,
        :password,
        :password2,
        :locale,
        :email,
        :username,
        :test_group_number,
        :community_id,
        :admin_emails_consent
    ).permit!
    result.merge(params.require(:person)
      .slice(:custom_field_values_attributes)
      .permit(
        custom_field_values_attributes: [
          :id,
          :type,
          :custom_field_id,
          :person_id,
          :file_upload_value,
          :text_value,
          :numeric_value,
          :'date_value(1i)', :'date_value(2i)', :'date_value(3i)',
          selected_option_ids: []
        ]
      )
    )
  end

  def create_user_default
    email = nil
    begin
      ActiveRecord::Base.transaction do
        user_password = SecureRandom.urlsafe_base64(6)
        params[:person][:password] = user_password
        params[:person][:password2] = user_password
        user_name = generate_username(params[:person][:given_name],params[:person][:family_name],@current_community.id)
        params[:person][:username] = user_name
        @person, email = new_person(params, @current_community)
        if @current_community
          membership = CommunityMembership.new(person: @person, community: @current_community, consent: @current_community.consent)
          membership.status = "accepted"
          # If the community doesn't have any members, make the first one an admin
          if @current_community.members.count == 0
            membership.admin = true
          end
          membership.save!
        end
        email.confirm!
        token = @person.reset_password_token_if_needed
        #UserMailer::Mandrill.reset_password(params[:email], token, @current_community, person , false)
        MailCarrier.deliver_now(PersonMailer.reset_password_for_user_by_admin(@person, email.address, token, @person.community)) 
      end
    flash[:notice] = "User is Saved !! User will receive a mail soon"
    redirect_to admin_community_community_memberships_path
    rescue => e
      flash[:error] = "Some error occured"
      #redirect_to error_redirect_path and return
    end
  end   

  def posting_allowed
    @service.posting_allowed
    render body: nil, status: 200
  end

  def resend_confirmation
    @service.resend_confirmation
    render body: nil, status: 200
  end

  def new
    @person_service = Person::SettingsService.new(community: @current_community, params: params,
                                           required_fields_only: true)
    @person_service.new_person
    
    render :new , locals: {image_s3_options: image_s3_options}
  end

  private

  def set_selected_left_navi_link
    @selected_left_navi_link = 'manage_members'
  end

  def set_service
    @service = Admin::Communities::MembershipService.new(
      community: @current_community,
      params: params,
      current_user: @current_user)
    @presenter = Admin::MembershipPresenter.new(
      service: @service,
      params: params)
  end

  def image_s3_options
    s3uploader = S3Uploader.new
    return s3uploader.signup_page_fields.to_json
  end
end
