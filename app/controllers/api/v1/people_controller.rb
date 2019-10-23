class Api::V1::PeopleController < Api::V1::ApplicationController
before_action :check_token , only: [:generate_token, :update_password]
before_action :authenticate_api_user , except: [:sign_up, :login, :generate_token, :update_password]
before_action :assign_person , only: [:update_password]

    def sign_up
      begin
        hsh = HashWithIndifferentAccess.new
        hsh[:message] = "Successful"
        hsh[:status] = "200"
        raise "Community is not available." unless Community.find_by_id(params.dig(:person, :community_id)).present?
        signup_params[:display_name] = params.dig(:person, :given_name)
        @current_user = Person.create!(signup_params)
        @current_user.create_token
        hsh[:data] = @current_user.get_person_signup_info
        render :json => hsh.to_json
      rescue Exception => e
        err_hash = HashWithIndifferentAccess.new
        err_hash[:message] = e.message
        err_hash[:status] = "400"
        inner_error_hsh = HashWithIndifferentAccess.new
        err_hash[:data] = inner_error_hsh
        render :json => err_hash.to_json
      end
    end

    def login
      begin
        hsh = HashWithIndifferentAccess.new
        hsh[:message] = "Successful"
        hsh[:status] = "200"
        raise "Community is not available." unless Community.find(params.dig(:person, :community_id)).present?
        @current_user = Person.find_by(email: params[:person][:email])
        raise "Email not found." unless @current_user.present?
        raise "Password is incorrect." unless @current_user.valid_password?(params[:person][:password])
        @current_user.create_token 
        @current_user.update_attributes(:device_type => params.dig(:person,:device_type))
        hsh[:data] = @current_user.get_person_info
        render :json => hsh.to_json
      rescue Exception => e
        err_hash = HashWithIndifferentAccess.new
        err_hash[:message] = "Error"
        err_hash[:status] = "400"
        inner_error_hsh = HashWithIndifferentAccess.new
        err_hash[:data] = inner_error_hsh
        render :json => err_hash.to_json
      end   
    end

    def generate_token
      begin
        hsh = HashWithIndifferentAccess.new
        hsh[:message] = "Successful"
        hsh[:status] = "200"
        inner_hsh = HashWithIndifferentAccess.new
        inner_hsh[:uuid] = UUIDTools::UUID.timestamp_create.hexdigest
        inner_hsh[:person_id] = SecureRandom.urlsafe_base64
        hsh[:data] = inner_hsh
        render :json => hsh.to_json
      rescue Exception => e
        err_hash = HashWithIndifferentAccess.new
        err_hash[:message] = "Error"
        err_hash[:status] = "400"
        inner_error_hsh = HashWithIndifferentAccess.new
        err_hash[:data] = inner_error_hsh
        render :json => err_hash.to_json
      end
    end
    
    def update_password
      begin
        raise "Person not found." unless @person.present?
        @person.update(:password => params.dig(:person, :password))        
        hsh = HashWithIndifferentAccess.new
        hsh[:message] = "Successful updated password."
        hsh[:status] = "200"
        inner_hsh = HashWithIndifferentAccess.new
        hsh[:data] = inner_hsh
        render :json => hsh.to_json
      rescue Exception => e
        err_hash = HashWithIndifferentAccess.new
        err_hash[:message] = "Error"
        err_hash[:status] = "400"
        inner_error_hsh = HashWithIndifferentAccess.new
        err_hash[:data] = inner_error_hsh
        render :json => err_hash.to_json
      end
    end

  private
    def assign_person
      @person = Person.find_by_id(params.dig(:person, :id))
    end

    def signup_params
      params.require(:person).permit(:community_id, :given_name, :family_name, :display_name, :password, :phone_number, :email, :username, :device_type)
    end    
end
