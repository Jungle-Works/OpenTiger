class Admin::CommunityPlansController < Admin::AdminBaseController

	before_action :fetch_current_plan, except: [:warning_popup_viewed]
	before_action :fetch_all_plans, only: [:index]
	before_action :fetch_my_card, only: [:index, :add_card]

  CLP = CustomLandingPage

  helper CLP::MarkdownHelper

	def index
    @plan_expired = @current_community.check_if_plan_has_expired(@current_billing_plan["expiry_datetime"].to_date, @current_plan_data["plan_code"]) #returns "ok" if plan not expired, "warning" if plan expire time left is less than 5 days and "stop" if plan has expired.
    @monthly_plans = Plan.fetch_required_plans(@plans,[8,9,10])
		@yearly_plans = Plan.fetch_required_plans(@plans,[8,11,12])
    @selected_left_navi_link = "billing"
  end

  def add_card
	begin
		# fetch_card_token = Community.create_card_token(card_params)
		@response = @current_community.add_card(@auth_user[:access_token],params[:payment_method])
		@card = @current_community.my_card(@auth_user[:access_token])
		Community.fugu_bot_token_added(@auth_user_all_detail,"successfully_added_card",comment="") if @response["status"] && @response["status"] == 200
		render :json => @card.to_json
	rescue Exception => e
		err_hash = HashWithIndifferentAccess.new
		err_hash[:message] = e.message
		err_hash[:status] = "400"
		inner_hsh = HashWithIndifferentAccess.new
		err_hash[:data] = inner_hsh
		Community.fugu_bot_token_added(@auth_user_all_detail,"error_on_add_card",e.message)
		render :json => err_hash.to_json
	end
  end

  #for stripe webview
 

  #view warning popup
	def warning_popup_viewed
		begin
			@current_community.update(:last_expiry_popup_view_date => Date.today)
			hsh = HashWithIndifferentAccess.new
			hsh[:message] = "Successful"
			hsh[:status] = "200"
			hsh[:data] = {}
			render :json => hsh.to_json
		rescue Exception => e
				puts e
			err_hash = HashWithIndifferentAccess.new
			err_hash[:message] = "Error"
			err_hash[:status] = "400"
			inner_hsh = HashWithIndifferentAccess.new
			err_hash[:data] = inner_hsh
			render :json => err_hash.to_json
		end
  end

  def setup_intent

	begin
		if Rails.env.production?
		  @url     ="https://#{APP_CONFIG.auth_api_key}/billing/setupIntent"
		  @authKey = APP_CONFIG.auth_api_key
		else
		  @url     = "https://dev-#{APP_CONFIG.auth_api_key}:3018/billing/setupIntent"
		  @authKey = APP_CONFIG.auth_api_key
		end
		uri = URI(@url)
		https = Net::HTTP.new(uri.host, uri.port)
		https.use_ssl = true
		req = Net::HTTP::Post.new(uri.path, {'Content-Type' =>'application/json'});
		req.body ={			
		  :access_token  => params[:access_token],
		  :auth_key  => @authKey,
		  :offering  => 2
		}.to_json
		res1 = https.request(req)
		stripe_intent = JSON.parse(res1.body)
		secret_key = stripe_intent["data"]["client_secret"]
		hsh = HashWithIndifferentAccess.new
		hsh[:message] = "Successful"
		hsh[:status] = "200"
		hsh[:data] = {:id=> secret_key}
		render :json => hsh.to_json
		
	  rescue Exception => e
		err_hash = HashWithIndifferentAccess.new
		err_hash[:message] = "Error"
		err_hash[:status] = "400"
		err_hash[:data] = {}
		render :json => err_hash.to_json
		
	  end

  end

  private
    def card_params
      params.require(:card).permit(:number, :exp_month, :exp_year, :cvc)
		end
		
		def fetch_my_card
	 		@card = @current_community.my_card(@auth_user[:access_token])
		end
		
		def fetch_all_plans
			@plans = Community.fetch_plans(@auth_user[:access_token])
		end
end
