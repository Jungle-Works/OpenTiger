class ContentPageService::LoadContent 

    ContentPageModel = ::ContentPage

    def self.load_one(community: , end_point:, id:false , for_presenting:false)
        unless community || end_point 
            return []
        end    
        self.get_content_data(community: community, end_point: end_point ,id: id, for_presenting: for_presenting)
    end

    def self.load_all(community:)
        unless community 
            return []
        end  
        self.get_content_pages_for_community(community: community)
    end  
    private 

    def self.get_content_data(community: , end_point: , id:, for_presenting:)
        if id
            content_page = ContentPageModel.find_by(id: id)
        else  
            if for_presenting
                content_page = ContentPageModel.find_by(end_point: end_point, community: community, is_active: true)
            else
                content_page = ContentPageModel.find_by(end_point: end_point, community: community)
            end  
        end  
        return content_page ? id ? content_page : content_page[:data].html_safe : nil 
    end   

    def self.get_content_pages_for_community(community:)
        content_pages = ContentPage.where("community_id = ? ",community)
        return content_pages.length ? content_pages : []
    end  
end  