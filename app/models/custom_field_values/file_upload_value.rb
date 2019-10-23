# == Schema Information
#
# Table name: custom_field_values
#
#  id                :integer          not null, primary key
#  custom_field_id   :integer
#  listing_id        :integer
#  text_value        :text(65535)
#  numeric_value     :float(24)
#  date_value        :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  type              :string(255)
#  delta             :boolean          default(TRUE), not null
#  person_id         :string(255)
#  file_upload_value :text(65535)
#
# Indexes
#
#  index_custom_field_values_on_listing_id  (listing_id)
#  index_custom_field_values_on_person_id   (person_id)
#  index_custom_field_values_on_type        (type)
#

class FileUploadValue < CustomFieldValue

  validates :file_upload_value, presence: true, if: proc { |file_upload_value| file_upload_value.question.required? }

  def display_value
    file_upload_value
  end
end
