# app/helpers/components_helper.rb
module ComponentsHelper

  # Main method to render component (simplified version)
  def render_component_for_website(component, theme_page, website = nil)
    # For now, just render the component HTML with edit wrapper if in builder mode
    html = component.html_content || ""

    # Apply basic placeholder replacements
    html = process_basic_placeholders(html, component)

    # Wrap component for editing if in builder mode
    if params[:action] == 'builder' && website
      html = wrap_component_for_editing(html, component, theme_page)
    end

    html.html_safe
  end

  # Process basic placeholders in component HTML
  def process_basic_placeholders(html, component)
    # Replace common placeholders with default values
    replacements = {
      '{{title}}' => 'Sample Title',
      '{{subtitle}}' => 'Sample Subtitle',
      '{{content}}' => 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
      '{{text}}' => 'Sample text content',
      '{{button_text}}' => 'Click Here',
      '{{image_url}}' => 'https://via.placeholder.com/300x200',
      '{{background_color}}' => '#3b82f6',
      '{{color}}' => '#374151',
      '{{logo}}' => 'Logo',
      '{{link_url}}' => '#'
    }

    replacements.each do |placeholder, default_value|
      html = html.gsub(placeholder, default_value)
    end

    html
  end

  # Wrap component with editing controls
  def wrap_component_for_editing(html, component, theme_page)
    <<~HTML
      <div class="editable-component" 
           data-component-id="#{component.id}" 
           data-theme-page-id="#{theme_page.id}"
           data-component-name="#{component.name}">
        <div class="component-overlay">
          <button class="edit-component-btn" 
                  data-component-id="#{component.id}"
                  data-theme-page-id="#{theme_page.id}">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"></path>
            </svg>
            Edit #{component.name}
          </button>
        </div>
        <div class="component-content">
          #{html}
        </div>
      </div>
    HTML
  end

  # Helper method for getting component field types for JavaScript
  def component_field_types_json(component)
    if component.respond_to?(:field_types_hash)
      component.field_types_hash.to_json
    else
      '{}'.to_json
    end
  end

  # Helper method to get customizations as JSON
  def component_customizations_json(component, theme_page, website)
    if defined?(WebsiteCustomization) && website
      customizations = WebsiteCustomization.for_component(website.id, component.id, theme_page.id)
      customizations.to_json
    else
      '{}'.to_json
    end
  end
end