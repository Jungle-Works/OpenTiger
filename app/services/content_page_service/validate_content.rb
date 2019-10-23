class ContentPageService::ValidateContent  

    ContentPageModel = ::ContentPage

    def self.validate(end_point:, community:, id:nil)
        unless end_point || community 
            return { "success" => false , "message" => "end_point / community missing"}
        end  
        response = self.end_point_exists(end_point: end_point, community: community, id: id)
    end  
    private  

    def self.end_point_exists(end_point: , community:, id:)  
        page = ContentPageModel.find_by(community_id: community, end_point: end_point)
        unless page.nil? || page[:id].to_s == id
            return { "success" => false , "message" => "end point not available"}
        end  
        { "success" => true, "message" => "available end point" }
    end  
end  
