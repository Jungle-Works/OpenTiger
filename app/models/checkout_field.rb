# == Schema Information
#
# Table name: checkout_fields
#
#  id            :integer          not null, primary key
#  people_id     :string(255)      not null
#  community_id  :integer          not null
#  sort_priority :integer
#  field_type    :string(255)
#  title         :string(255)
#  value         :string(10000)
#  locale        :string(255)
#  is_required   :boolean          default(TRUE)
#  entity_type   :string(255)
#  min           :float(24)
#  max           :float(24)
#  is_deleted    :boolean          default(FALSE)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_checkout_fields_on_community_id  (community_id)
#  index_checkout_fields_on_people_id     (people_id)
#

class CheckoutField < ApplicationRecord
  VALID_TYPES = ["TextField", "DropdownField", "FileUpload"]

  def checkout_field_options
    parsed_values = []
    if field_type == "DropdownField"
      if valid_json?(value)
        parsed_values = JSON.parse(value)
        if valid_json?(parsed_values)
          parsed_values = JSON.parse(parsed_values)
        end
      end
    end
    return parsed_values
  end

  private

  def valid_json?(json)
    begin
      JSON.parse(json)
      return true
    rescue => e
      return false
    end
  end

end
