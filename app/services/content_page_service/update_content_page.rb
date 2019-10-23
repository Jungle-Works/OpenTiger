class ContentPageService::UpdateContentPage  

    ContentPageModel = ::ContentPage

    def self.update_content(title: , end_point: , data: , id:, community:)
        unless id || self.id_exits?(id: id)
            return { "success" => false , "data" => "ID not given / doesn't exists"}
        end 
        unless self.data_is_valid(title: title, end_point: end_point)
            return { "success" => false , "message" => "Update data is invalid"}
        end  
        checkRes = ContentPageService::ValidateContent.validate(end_point: end_point, community: community, id:id)
        unless checkRes["success"] == true 
            return { "success" => false , "message" => "End point already exists" , "title" => title , "end_point" => end_point , "data" => data }
        end
        data = data.html_safe
        ContentPageModel.find_by(id: id).update_attributes(
            :title => title,
            :end_point => end_point,
            :data => data 
        )
        return { "success" => true , "data" =>  "successfull update"}
    end
    
    def self.update_active(id: , value:)
        unless id || self.id_exits?(id: id)
            return { "success" => false , "data" => "ID not given / doesn't exists"}
        end 
        ContentPageModel.find_by(id: id).update_attribute(:is_active, value)
        return { "success" => true, "data" => "successfull"}
    end  

    private 

    def self.id_exits?(id:)
        return ContentPageModel.find_by(id: id) ? true : false 
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