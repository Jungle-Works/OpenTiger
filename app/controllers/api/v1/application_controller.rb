class Api::V1::ApplicationController < ActionController::API
  before_action :set_api_format
  before_action :authenticate_api_user
  before_action :check_token

  def authenticate_api_user
    begin
      if current_user.present?
        @current_api_user = current_user
      else
        raise "Please add apisecret in headers" if request.headers["HTTP_APISECRET"].blank?
        puts request.headers["HTTP_APISECRET"]
        @current_api_user = Person.find_by_app_password(request.headers["HTTP_APISECRET"])
        raise "Unable to fetch user." unless @current_api_user.present?
      end
    rescue Exception => @e
        err_hash = HashWithIndifferentAccess.new
        err_hash[:message] = "Error"
        err_hash[:status] = "400"
        inner_hsh = HashWithIndifferentAccess.new
        err_hash[:data] = inner_hsh
        render :json => err_hash.to_json
    end
  end

  def check_token
    begin
        raise "Please add api token in headers." if request.headers["HTTP_APITOKEN"].blank?
        puts request.headers["HTTP_APITOKEN"]
        raise "Invalid api token." unless request.headers["HTTP_APITOKEN"] == "oX/7JLzGgUF+su3AOqv1rkHi+V7O1wQBcvcJbxNmC/Q="
    rescue Exception => @e
        err_hash = HashWithIndifferentAccess.new
        err_hash[:message] = "Error"
        err_hash[:status] = "400"
        inner_hsh = HashWithIndifferentAccess.new
        err_hash[:data] = inner_hsh
        render :json => err_hash.to_json
    end
  end

  def set_api_format
    request.format = :json
  end

  def show_error!(msg = "Something went wrong.Please try again later.", status = 400, data = HashWithIndifferentAccess.new)
    err_hash             = HashWithIndifferentAccess.new
    err_hash[:message]   = msg
    err_hash[:status]    = status
    err_hash[:data]      = data

    render :json => err_hash.to_json
  end
  
  def success_msg(data = HashWithIndifferentAccess.new, msg =" Action complete", status = 200)
    suss_hash            = HashWithIndifferentAccess.new
    suss_hash[:message]  = msg
    suss_hash[:status]   = status
    suss_hash[:data]     = data

    render :json => suss_hash.to_json
  end
end