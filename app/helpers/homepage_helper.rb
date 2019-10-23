module HomepageHelper
  def show_subcategory_list(category, current_category_id)
    category.id == current_category_id || category.children.any? do |child_category|
      child_category.id == current_category_id
    end
  end

  def with_first_listing_image(listing, &block)
    if listing.listing_images.count >= 1
    Maybe(listing)
      .listing_images
      .map { |images| images.first }[:medium].each { |url|
      block.call(url)
    }
    else
      block.call("None")
    end
  end

  def without_listing_image(listing, &block)
    if listing.listing_images.size == 0
      block.call
    end
  end

  def format_distance(distance)
    precision = (distance < 1) ? 1 : 2
    (distance < 0.1) ? "< #{number_with_delimiter(0.1, locale: locale)}" : number_with_precision(distance, precision: precision, significant: true, locale: locale)
  end
  def highlight_clear(params,cus_field)
   
    prefix = cus_field.type == "CheckboxField" ? CustomFieldSearchParams.checkbox_prefix : CustomFieldSearchParams.dropdown_prefix

    cus_field.options.ids.each do |a| 
      if params.key?(prefix+a.to_s)
        return true
      end
    end
    return false
    
  end

  def highlight_price_clear_button(params)
    price_min = MoneyUtil.to_units(MoneyUtil.to_money(@current_community.price_filter_min, @current_community.currency))
    price_max = MoneyUtil.to_units(MoneyUtil.to_money(@current_community.price_filter_max, @current_community.currency))
    if params[:price_min].present? && params[:price_max].present?
      if params[:price_min].to_i == price_min && params[:price_max].to_i == price_max
        return false
      else 
        return true 
      end
    else
      return false
    end
  end

  def highlight_num_clear_button(cus_field,params)
    # puts "present " , cus_field.id

    min_input = CustomFieldSearchParams.numeric_min_param_name(cus_field.id)
    max_input = CustomFieldSearchParams.numeric_max_param_name(cus_field.id)
    if params[min_input].present? && params[max_input].present?
      if params[min_input].to_i == cus_field.min && params[max_input].to_i == cus_field.max
        return false
      else 
        return true 
      end
    else
      
      return false
    end
  end

end