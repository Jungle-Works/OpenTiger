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

class CustomFieldValue < ApplicationRecord

  belongs_to :listing
  belongs_to :question, :class_name => "CustomField", :foreign_key => "custom_field_id"
  belongs_to :person
  has_many :custom_field_option_selections

  delegate :with_type, :sort_priority, :to => :question

  default_scope { includes(:question).order("custom_fields.sort_priority") }

  scope :by_question, ->(question){ where(custom_field_id: question.id) }

  def cname
    question.names.last.value
  end

  def final_value
    if type == "CheckboxFieldValue" || type == "DropdownFieldValue"
      custom_field_option_selections.map{|a| a.custom_field_option_titles.pluck(:value).join(', ')}
    elsif type == "NumericFieldValue"
       numeric_value.to_s.lines.to_a
    elsif type == "TextFieldValue"
       text_value.lines.to_a
    elsif type == "DateFieldValue"
       date_value.strftime("%Y-%m-%d").lines.to_a
    end
  end
end
