class Admin::AdminDomainsController < ApplicationController
  before_action :set_selected_left_navi_link
  before_action :set_service

    def show
        @title = "hello"
    end

    def validate_domain

        begin
          
            temp = @current_community.community_domains.where("in_processing = 0")           
           temp2 = CommunityDomain.where(custom_domain: params[:domain], in_processing: [0,1])

        if temp.blank? && temp2.blank?


            @success = {
              "status" => 200,
              "message" => "success",
              "domain" => params[:domain]
                
            }
    
            render :json => @success.to_json

        else    

            puts "####################"
            puts temp,temp2

            @failure = {
                "status" => 201,
                "message" => "failure"
            }

            render :json => @failure.to_json
            


                
        end



        rescue => e

            @failure = {
                "status" => 201,
                "message" => "failure"
            }

            render :json => @failure.to_json
            


        end  

        

    end

    def update

        begin

            @current_community.community_domains.create(custom_domain: params[:domain], previous_domain: @current_community.domain)

            @success = {
              "status" => 200,
              "message" => "success",
              "domain" => params[:domain]
                
            }
    
            render :json => @success.to_json
            
           rescue => e

            @failure = {
                "status" => 201,
                "message" => "failure"
            }

            render :json => @failure.to_json
            
        end

      end

   def update_google_maps_key
     @current_community.update(:google_maps_key => Maybe(params[:google_maps_key]).or_else(nil))
     redirect_to admin_admin_domain_path(@current_community.id)
   end
      
    private


  def set_selected_left_navi_link
    @selected_left_navi_link = 'admin_domain'
  end

  def set_service
    @service = Admin::SettingsService.new(
      community: @current_community,
      params: params)
    @presenter = Admin::SettingsPresenter.new(service: @service)
  end

  
end