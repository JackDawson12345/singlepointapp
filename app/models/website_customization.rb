# app/models/website_customization.rb
class WebsiteCustomization < ApplicationRecord
  belongs_to :website
  belongs_to :component
  belongs_to :theme_page

  validates :field_name, presence: true
  validates :field_value, presence: true
  validate :field_name_is_editable

  # Get customization value for a specific field
  def self.get_value(website_id, component_id, theme_page_id, field_name)
    find_by(
      website_id: website_id,
      component_id: component_id,
      theme_page_id: theme_page_id,
      field_name: field_name
    )&.field_value
  end

  # Set customization value for a specific field
  def self.set_value(website_id, component_id, theme_page_id, field_name, field_value)
    customization = find_or_initialize_by(
      website_id: website_id,
      component_id: component_id,
      theme_page_id: theme_page_id,
      field_name: field_name
    )
    customization.field_value = field_value
    customization.save!
    customization
  end

  # Get all customizations for a component on a specific page
  def self.for_component(website_id, component_id, theme_page_id)
    where(
      website_id: website_id,
      component_id: component_id,
      theme_page_id: theme_page_id
    ).pluck(:field_name, :field_value).to_h
  end

  private

  def field_name_is_editable
    return unless component && field_name

    editable_fields = component.editable_fields_array
    unless editable_fields.include?(field_name)
      errors.add(:field_name, "#{field_name} is not an editable field for this component")
    end
  end
end