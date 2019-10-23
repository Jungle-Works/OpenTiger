class Admin::CheckoutSettingsController < Admin::AdminBaseController

  def new  
    @selected_field = params[:field_type]
    if params[:field_type] == "DropdownField"
    @checkout_field = {
      "value"=> [
        {"label"=> "", "price"=> "", "description"=> ""}
      ]
    }
    end
  end

  def index
    @selected_left_navi_link = "checkout_fields"
    @community = @current_community
    @checkout_fields = CheckoutField.where("community_id = #{@current_community.id}")
  end

  def requiresJSONParse(unit) 
    begin 
      JSON.parse(unit) 
    return true 
      rescue => e 
    return false 
      end 
    end


  def edit
    @checkout_field = CheckoutField.find_by(id: params[:id])
    @type = @checkout_field.field_type
    if @type=="DropdownField"
     if requiresJSONParse(@checkout_field)
      @checkout_field.value = JSON.parse(@checkout_field.value)
     end
    end
  end

  def add_checkout_field
    CheckoutField.create( 
      :people_id => @current_user.id, 
      :community_id => @current_community.id, 
      :title => params[:title] || '', 
      :value => params[:value] ? params[:value].values.to_json : '', 
      :field_type => params[:field_type], 
      :created_at => Time.new, 
      :updated_at => Time.new 
      ) 
    if params[:field_type] == "TextField" || params[:field_type] == "FileUpload" 
      redirect_to admin_checkout_settings_path 
    else 
      @success = { 
      "status" => 200, 
      "message" => "success" 
      } 
      render :json => @success.to_json 
    end
  end

  def update_checkout_field
    puts params
    @checkout_field = CheckoutField.find_by(id: params[:id])
    if @checkout_field.field_type == "TextField" || @checkout_field.field_type == "FileUpload"
      @checkout_field.update_attribute(:title, params[:title])
      redirect_to admin_checkout_settings_path
    else
      begin
        if params[:value].present?  
        @checkout_field.update_attribute(:title, params[:title])
        @checkout_field.update_attribute(:value, params[:value].values.to_json)
        end
        @success = {
          "status" => 200,
          "message" => "success" 
        }
        render :json => @success.to_json
      rescue => exception  
        puts exception
        @failure = {
          "status" => 201,
          "message" => "failure" 
        }
        render :json => @failure.to_json
      end
    end
    
  end
  
  def delete_checkout_field
    field = CheckoutField.find_by(id: params[:id])
    field.destroy
    redirect_to admin_checkout_settings_path
  end

  def change_checkout_type
    if params[:select_checkout_type] == "order"
      @current_community.update_attribute(:checkout_flow, 1)
    else
      @current_community.update_attribute(:checkout_flow, 0)
    
    end
    redirect_to admin_checkout_settings_path
  end

 

end

