module Admin::CheckoutFieldsHelper

  def checkout_field_type_translation(type)
    tranlation_map = {
      "DropdownField" => "admin.checkout_fields.index.dropdown",
      "TextField" => "admin.checkout_fields.index.text",
      "FileUpload" => "admin.checkout_fields.index.file_upload",
    }

    t(tranlation_map[type])
  end

  def checkout_field_dropdown_options(options)
    options.collect { |option| [checkout_field_type_translation(option), option] }.insert(0, [t("admin.custom_fields.index.select_one"), nil])
  end

end
