class Admin::ManageLandingPageController < Admin::AdminBaseController


  #version 1 => "saved", 2 => "released"
  # Shorthand for accessing CustomLandingPage service namespace
  MDLP = CustomLandingPage::LandingPageStore
  include ManageLandingPageHelper

  def index
    @selected_left_navi_link = "landing_page"
    @community = @current_community
    @is_enable = MDLP.enabled?(@current_community.id)
    # @released_landing_page_data = MDLP.load_structure(@current_community.id, 2)
    current_released_version = MDLP.get_current_released_version(@current_community.id)
    @landing_page_data = MDLP.load_structure(@current_community.id, current_released_version)
  end
  
  def image_s3_options
    s3uploader = S3Uploader.new
    return s3uploader.landing_page_fields.to_json
  end

  def preview
    begin
      MDLP.update_version!(@current_community.id, 3, params[:content])
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

  def edit
    @released_landing_page_data = MDLP.load_structure(@current_community.id, 2)
    current_released_version = MDLP.get_current_released_version(@current_community.id)
    @landing_page_data = MDLP.load_structure(@current_community.id, current_released_version)
    query_params = CGI.parse(request.query_string)
    @section_data = @landing_page_data["sections"].find{|section| section["id"] == params["id"]}
  
    if @section_data["kind"] == "listings"
      @listings = @current_community.listings.map{|listing| { "id" => listing["id"], "title" => listing["title"]}}
    end
    if @section_data["kind"] == "categories"
      @categories = @current_community.categories.map{|category| { "id" => category["id"], "title" => category["url"]}}
    end
    @form_type = "edit_form";
    render locals:{query_params: query_params, image_s3_options: image_s3_options}
  end


  def new
    @released_landing_page_data = MDLP.load_structure(@current_community.id, 2)
    current_released_version = MDLP.get_current_released_version(@current_community.id)
    @landing_page_data = MDLP.load_structure(@current_community.id, current_released_version)
    query_params = CGI.parse(request.query_string)
    @section_data = getLandingPageSectionTemplate(params["kind"],Maybe(params["variation"]).or_else(""), params["id"])
    @form_type = "add_form";
    @listings = [];
    @categories = [];
    if @section_data["kind"] == "listings" && @current_community.listings.present?
      @listings = @current_community.listings.currently_open.map{|listing| { "id" => listing["id"], "title" => listing["title"]}}
    end
    if @section_data["kind"] == "categories" && @current_community.categories.present?
      @categories = @current_community.categories.map{|category| { "id" => category["id"], "title" => category["url"]}}
    end
    render locals:{query_params: query_params,image_s3_options: image_s3_options}
  end

  def enable_lp
    begin
      MDLP.enable_landing_page(@current_community.id)
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

  def disable_lp
    begin
      MDLP.disable_landing_page(@current_community.id)
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

  def enable_disable_lp
    begin
      @is_enable = MDLP.enabled?(@current_community.id)
      if @is_enable.present?
        MDLP.disable_landing_page(@current_community.id)
      else
        MDLP.enable_landing_page(@current_community.id)
      end
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

  def save_only
    begin
        get_released_version = MDLP.get_current_released_version(@current_community.id)
        MDLP.update_and_release_version!(@current_community.id, get_released_version, params[:content])
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

  #no need to release-version as version 2 will be automatically released while creating market place.
  def save_and_release
    begin
      MDLP.update_version!(@current_community.id, 1, params[:content])
      MDLP.update_version!(@current_community.id, 2, params[:content])
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
end
