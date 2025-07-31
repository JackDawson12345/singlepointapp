# app/models/website.rb
class Website < ApplicationRecord
  belongs_to :user
  belongs_to :theme
  has_many :website_customizations, dependent: :destroy

  # Get customized content for a component
  def get_customized_content(component, theme_page)
    customizations = WebsiteCustomization.for_component(id, component.id, theme_page.id)
    component.render_with_customizations(customizations)
  end

  # Check if website has any customizations
  def has_customizations?
    website_customizations.exists?
  end
end

# app/models/component.rb
class Component < ApplicationRecord
  has_many :theme_page_components, dependent: :destroy
  has_many :website_customizations, dependent: :destroy

  # Parse editable_fields into an array
  def editable_fields_array
    return [] if editable_fields.blank?
    editable_fields.split(',').map(&:strip)
  end

  # Parse template_patterns JSON
  def template_patterns_hash
    return {} if template_patterns.blank?
    JSON.parse(template_patterns)
  rescue JSON::ParserError
    {}
  end

  # Parse field_types JSON
  def field_types_hash
    return {} if field_types.blank?
    JSON.parse(field_types)
  rescue JSON::ParserError
    {}
  end

  # Render component with customizations
  def render_with_customizations(customizations = {})
    content = html_content.dup

    # Apply customizations to placeholders
    editable_fields_array.each do |field|
      placeholder = "{{#{field}}}"
      if content.include?(placeholder)
        custom_value = customizations[field] || get_default_value(field)
        content.gsub!(placeholder, custom_value.to_s)
      end
    end

    content
  end

  # Get default value for a field based on field name
  def get_default_value(field_name)
    case field_name.downcase
    when 'title'
      'Default Title'
    when 'subtitle'
      'Default Subtitle'
    when 'text', 'content'
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'
    when 'button_text'
      'Click Here'
    when 'image_url'
      '/assets/placeholder-image.jpg'
    when 'logo'
      'Logo'
    else
      "Default #{field_name.humanize}"
    end
  end

  # Check if a field is editable
  def field_editable?(field_name)
    editable_fields_array.include?(field_name.to_s)
  end
end

# app/models/theme.rb
class Theme < ApplicationRecord
  has_many :theme_pages, dependent: :destroy
  has_many :websites, dependent: :destroy

  # Get all components for this theme with their customizations for a specific website
  def components_for_website(website)
    Component.joins(theme_page_components: { theme_page: :theme })
             .where(theme_pages: { theme_id: id })
             .distinct
  end
end