class ContentPageLoadController < ApplicationController
    before_action :perform_validations
    def load  
        if @marketplace_id.nil? || @end_point.nil?
            render locals: {content: "Invalid Community or Page Name"}
        end   
        content = ContentPageService::LoadContent.load_one(community: @marketplace_id, end_point: @end_point, for_presenting: true)
        content = "404 !! No Page Found" if content.nil?
        render locals: { content: content }
    end
    private
    def perform_validations 
        unless params[:id] 
            render locals: { content: "Page ID is required !!"}
        end  
        @marketplace_id = Maybe(request.env[:current_marketplace].id).or_else(nil)
        @end_point = Maybe(params[:id]).or_else(nil)
    end  
end