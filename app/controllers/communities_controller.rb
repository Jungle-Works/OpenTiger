class CommunitiesController < ApplicationController
  skip_before_action :fetch_community,
              :perform_redirect,
              :cannot_access_if_banned,
              :cannot_access_without_confirmation,
              :ensure_consent_given,
              :ensure_user_belongs_to_community

  before_action :ensure_no_communities

  layout 'blank_layout'
  include CommunitiesHelper
  NewMarketplaceForm = Form::NewMarketplace

  def new
    @form_fields = {};
    render_form
  end

  def create
    form = NewMarketplaceForm.new(params)
    @form_fields = form.to_hash
    if form.valid?
      form_hash = form.to_hash
      PreMarketPlaceWork
    else
     render_form(errors: form.errors.full_messages)
   end
  end

 private
     
  def PreMarketPlaceWork

      #create marketplace
      marketplace = MarketplaceService.create(
        @form_fields.slice(:marketplace_name,
          :marketplace_type,
          :marketplace_country,
          :marketplace_language)
         )

      #create admin user 
      user = UserService::API::Users.create_user({
        given_name: @form_fields[:admin_first_name],
        family_name: Maybe(@form_fields[:admin_last_name]).or_else(""),
        email: @form_fields[:admin_email],
        password: @form_fields[:admin_password],
        is_admin: 1,
        locale: @form_fields[:marketplace_language]},
        marketplace.id).data

      #setup payments and feature flags
      setup_landing_page(marketplace[:id])
      setup_default_theme(marketplace[:id])
      enablePaymentMethod(marketplace)
      setDefaultFeature(marketplace[:id])

      @user_token = auth_token[:token]
      url = URLUtils.append_query_param(marketplace.full_domain({with_protocol: true}), "auth", @user_token)
      redirect_to url

    end

  def render_form(errors: nil)
    puts "#########,errors,#{errors},#{communities_path}"
    queryStr = request.query_string
    formPath = Maybe(communities_path).split("?")[0].or_else("") + (!queryStr.empty? ? queryStr.prepend("?") : "")
    if !queryStr.empty? 
      if queryStr.include? "access_token"
        formPath =formPath + '&errors=' + Maybe(errors)[0].or_else("")
      end
    end
    render action: :new, locals: {
             title: 'Create a new marketplace',
             form_action: formPath,
             errors: errors,
             form_fields: @form_fields
           }
  end

  def ensure_no_communities
    redirect_to landing_page_path if communities_exist?
  end


  def setup_landing_page(marketplace_id)
    user_color = "#4a90e2"
    user_color_without_hsh = "4a90e2"
    primary_color_val = ColorUtils.css_to_rgb_array(user_color)
    darken_code = ColorUtils.brightness(user_color_without_hsh,85)
    primary_color_darken_val = ColorUtils.css_to_rgb_array(darken_code)            

    parsed_data = JSON.parse(CustomLandingPage::StaticData::DATA_STR)
    if parsed_data.keys.include?("settings").present?
      settings_data = parsed_data.find{|inner_data| inner_data.first == "settings"}
      if settings_data.present?
        if settings_data.second.keys.include?("marketplace_id")
          settings_data.second["marketplace_id"] = marketplace_id
        end
      end
    end
    if parsed_data.keys.include?("sections").present?
      sections_data = parsed_data.find{|inner_data| inner_data.first == "sections"}
      if sections_data.present?
        sections_data.second.each do |a| 

          if a["kind"] != "hero"
            a.each do |key,value|
              if value.is_a? Hash
                if value["id"]=="primary_color"
                  a[key] = {"value"=> primary_color_val}
                end
                if value["id"]=="primary_color_darken"
                  a[key] = {"value"=> primary_color_darken_val}
                end
              end
            end
          end
          
        end
      end
    end
    final_json = parsed_data.to_json
    CustomLandingPage::LandingPageStore.create_landing_page!(marketplace_id) 
    CustomLandingPage::LandingPageStore.create_version!(marketplace_id, 1, final_json) 
    CustomLandingPage::LandingPageStore.create_version!(marketplace_id, 2, final_json) 
    CustomLandingPage::LandingPageStore.create_version!(marketplace_id, 3, final_json) 
    CustomLandingPage::LandingPageStore.release_version!(marketplace_id, 1)
    CustomLandingPage::LandingPageStore.disable_landing_page(marketplace_id)
  end

  def setup_default_theme(marketplace_id)
    selected_theme = Theme.first
    current_marketplace = Community.find_by_id(marketplace_id)
    current_marketplace.community_themes.create(theme_id: selected_theme.id, content: selected_theme.content, enabled: true, released_at: Time.now)
  end

  def enablePaymentMethod(marketplace)

    PaymentSettings.create(community_id: marketplace[:id], active: true, confirmation_after_days: 14, payment_gateway: "paypal", minimum_transaction_fee_cents: 0, minimum_transaction_fee_currency: marketplace[:currency], payment_process: "preauthorize", commission_from_seller: 0)
    TransactionService::API::Api.processes.create(community_id: marketplace[:id], process: :preauthorize, author_is_seller: true)
    TransactionService::API::Api.settings.provision(community_id: marketplace[:id], payment_gateway: :stripe, payment_process: :preauthorize, active: true)
    if marketplace[:country]  && marketplace[:country] == "IN" 
    TransactionService::API::Api.settings.provision(community_id: marketplace[:id], payment_gateway: :razorpay, payment_process: :preauthorize, active: true)
    end
  end

  def setDefaultFeature(marketplaceID)

    FeatureFlagService::API::Api.features.enable(community_id: marketplaceID,features: [:topbar_v1])
    FeatureFlagService::API::Api.features.disable(community_id: marketplaceID,features: [:searchpage_v1])
    # FeatureFlagService::API::Api.features.enable(community_id: marketplaceID,features: [:new_stripe_api])
    FeatureFlagService::API::Api.features.enable(community_id: marketplaceID,features: [:approve_listings])
    FeatureFlagService::API::Api.features.enable(community_id: marketplaceID,features: [:login_google_linkedin])

  end


  def communities_exist?
    Rails.env.test? ? false : Community.count > 0
  end
end
