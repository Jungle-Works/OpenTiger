class Admin::ContentPagesController < Admin::AdminBaseController
  before_action :set_selected_left_navi_link
  before_action :set_service

  def set_selected_left_navi_link
    @selected_left_navi_link = 'content_pages'
  end

  def set_service
    @service = Admin::SettingsService.new(
      community: @current_community,
      params: params)
    @presenter = Admin::SettingsPresenter.new(service: @service)
  end

  def show
    @content_pages_list = ContentPageService::LoadContent.load_all(community: @current_community.id)
  end

  def add_content_page
    url = @current_community.full_url + "/pages/content/"
    render locals: {content_page_url: url}
  
  end

  def new_content_page
    return_val = ContentPageService::CreateContentPage.create(:end_point => params[:url], :community => @current_community.id, :data => params[:content_desc] , :title => params[:title])
    if return_val["success"] == true
      render :json => { "status" => 200 , "messagge" => ""}.to_json 
    else  
      render :json => {"status" => 400, "message" => return_val["message"]}.to_json
    end 
  end

  def edit
    @content_page = ContentPageService::LoadContent.load_one(community: @current_community.id, end_point: "",id: params[:id] )
    @content = @content_page.data.html_safe
    url = @current_community.full_url + "/pages/"
    render locals: {content_page_url: url}
  end

  def update_content_page
    return_val = ContentPageService::UpdateContentPage.update_content(:id => params[:id], :end_point => params[:url], :data => params[:content_desc] , :title => params[:title], :community => @current_community.id)
    if return_val["success"] == true
      render :json => { "status" => 200 , "messagge" => ""}.to_json 
    else  
      render :json => {"status" => 400, "message" => return_val["message"]}.to_json
    end  
  end

  def delete_content_page
    @content_page = ContentPageService::LoadContent.load_one(community: @current_community.id, end_point: "",id: params[:id] )
    @content_page.destroy
    redirect_to admin_content_page_path(@current_community)
  end

  def update_active_status
    return_val = ContentPageService::UpdateContentPage.update_active(:id => params[:id], :value => params[:status])
    if return_val["success"] == true
      render :json => { "status" => 200 }.to_json 
    else  
      render :json => {"status" => 400}.to_json
    end 
  end
  


end