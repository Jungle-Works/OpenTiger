class ContentPageService::CreateContentPage  

    ContentPageModel = ::ContentPage

    def self.create(end_point: , community: , data: , title:)   
        unless end_point || community || data || title
            return { "success" => false , "message" => "End point or title or data not given" } 
        end 
        unless self.data_is_valid(title: title, end_point: end_point)
            return { "success" => false , "message" => "Data is invalid"}
        end  
        checkRes = ContentPageService::ValidateContent.validate(end_point: end_point, community: community)
        unless checkRes["success"] == true 
            return { "success" => false , "message" => "End point already exists" , "title" => title , "end_point" => end_point , "data" => data }
        end 
        if self.save(end_point: end_point, community: community, data: data , title:title)
            return { "success" => true , "message" => "Content page saved successfully !" }
        end  
        return { "success" => false , "message" => "Some Error Occured !" } 
    end  

    private  

    def self.save(end_point: , community: , data: , title:) 
        data = data.html_safe
        if ContentPageModel.create(:end_point => end_point , :community_id => community , :data => data, :title => title)    
            return true  
        end
        return false    
    end  

    def self.data_is_valid(title:, end_point:)
        if self.empty_or_nil?(title) || self.empty_or_nil?(end_point)
            return false   
        end  
        return true 
    end  

    def self.empty_or_nil?(value)
        if value == "" || value == nil  
        return true
        end  
        return false 
    end  

end   