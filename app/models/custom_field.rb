# == Schema Information
#
# Table name: custom_fields
#
#  id             :integer          not null, primary key
#  type           :string(255)
#  sort_priority  :integer
#  search_filter  :boolean          default(TRUE), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  community_id   :integer
#  required       :boolean          default(TRUE)
#  min            :float(24)
#  max            :float(24)
#  allow_decimals :boolean          default(FALSE)
#  entity_type    :integer          default("for_listing")
#  public         :boolean          default(FALSE)
#  assignment     :integer          default("unassigned")
#
# Indexes
#
#  index_custom_fields_on_community_id   (community_id)
#  index_custom_fields_on_search_filter  (search_filter)
#

class CustomField < ApplicationRecord
  include SortableByPriority # use `sort_priority()` for sorting

  has_many :names, class_name: "CustomFieldName", dependent: :destroy

  has_many :category_custom_fields, dependent: :destroy
  has_many :categories, through: :category_custom_fields

  has_many :answers, class_name: "CustomFieldValue", dependent: :destroy

  has_many :options, class_name: "CustomFieldOption"

  belongs_to :community

  scope :sorted, ->{ order('custom_fields.sort_priority ASC') }
  scope :dropdown, ->{ where("type = 'DropdownField'") }
  scope :numeric, ->{ where("type = 'NumericField'") }
  scope :max_priority, ->{ select('MAX(sort_priority) AS priority') }
  scope :is_public, ->{ where(public: true) }
  scope :required, ->{ where(required: true) }

  ENTITY_TYPES = {
    for_listing: 0,
    for_person: 1
  }.freeze

  enum entity_type: ENTITY_TYPES

  ASSIGNMENTS = {
    unassigned: 0,
    phone_number: 1
  }.freeze

  enum assignment: ASSIGNMENTS

  VALID_TYPES = ["TextField", "NumericField", "DropdownField", "CheckboxField","DateField"]
  PERSON_CUST_FIELD_VALID_TYPES = ["TextField", "NumericField", "DropdownField", "CheckboxField","DateField", "FileUpload"]

  validates_length_of :names, minimum: 1
  validates :category_custom_fields, length: { minimum: 1 }, if: proc { |field| field.for_listing? }
  validates_presence_of :community

  def name_attributes=(attributes)
    build_attrs = attributes.map { |locale, value| {locale: locale, value: value } }
    build_attrs.each do |name|
      if existing_name = names.find_by_locale(name[:locale])
        existing_name.update_attribute(:value, name[:value])
      else
        names.build(name)
      end
    end
  end

  def category_attributes=(attributes)
    category_custom_fields.clear
    attributes.each { |category| category_custom_fields.build(category) }
  end

  def name(locale="en")
    TranslationCache.new(self, :names).translate(locale, :value)
  end

  def with(expected_type, &block)
    with_type do |own_type|
      if own_type == expected_type
        block.call
      end
    end
  end

  def with_type(&block)
    throw "Implement this in the subclass"
  end

  def get_listing_ids(values)
    case type
    
    when "NumericField"
      get_numeric_listing_ids(values)
    when "CheckboxField"
      get_checkbox_listing_ids(values)
    when "DropdownField"
      get_dropdown_listing_ids(values)
    when "TextField"
      get_text_listing_ids(values)
    when "DateField"
      get_date_listing_ids(values)
    else
      []
    end
  end

  def get_numeric_listing_ids(values)
    return [] unless values.count == 2
    answers.where(:numeric_value => values[0]..values[1]).pluck(:listing_id)
  end

  def get_checkbox_listing_ids(values)
    answers.joins(:custom_field_option_selections).where(:custom_field_option_selections => {:custom_field_option_id => values}).pluck(:listing_id)
  end

  def get_dropdown_listing_ids(values)
    answers.joins(:custom_field_option_selections).where(:custom_field_option_selections => {:custom_field_option_id => values}).pluck(:listing_id)
  end

  def get_text_listing_ids(values)
    answers.where("text_value like ?","%#{values}%").pluck(:listing_id)
  end

  def get_date_listing_ids(values)
    answers.where(:date_value => values.to_date).pluck(:listing_id)
  end

end
