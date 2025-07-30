# app/helpers/components_helper.rb
module ComponentsHelper
  def process_component_template(component, theme = nil, current_page = nil)
    return component.html_content if component.html_content.blank?

    html = component.html_content.dup

    # Process template patterns if they exist
    if component.template_patterns.present?
      html = process_template_patterns(html, component.template_patterns, theme, current_page)
    end

    # Process simple placeholders (like {{logo}})
    html = process_simple_placeholders(html, component, theme)

    html
  end

  private

  def process_template_patterns(html, template_patterns_json, theme, current_page = nil)
    begin
      # Parse the template patterns JSON
      patterns = JSON.parse(template_patterns_json)

      patterns.each do |placeholder, pattern_config|
        case placeholder
        when 'nav_items'
          html = process_nav_items(html, pattern_config, theme, current_page)
          # Add more pattern types here as needed
        end
      end
    rescue JSON::ParserError => e
      Rails.logger.error "Failed to parse template patterns: #{e.message}"
    end

    html
  end

  def process_nav_items(html, pattern_config, theme, current_page = nil)
    return html unless theme&.theme_pages&.any?

    # Get the template for individual nav items
    nav_item_template = extract_nav_item_template(pattern_config)

    # Generate nav items for each theme page
    nav_items_html = theme.theme_pages.order(:component_order).map do |theme_page|
      # Create the preview URL for each page
      preview_url = Rails.application.routes.url_helpers.admin_preview_theme_page_path(
        theme_id: theme.id,
        id: theme_page.id
      )

      # Replace placeholders in the template
      nav_item_html = nav_item_template.gsub('{{nav_item}}', theme_page.page_type)

      # Update the href attribute to point to the preview page
      nav_item_html = nav_item_html.gsub('href="#"', "href=\"#{preview_url}\"")

      # Highlight current page by adding different styling
      if current_page && current_page.id == theme_page.id
        nav_item_html = nav_item_html.gsub(
          'text-gray-900 hover:text-blue-600',
          'text-blue-600 font-semibold bg-blue-50'
        )
      end

      nav_item_html
    end.join("\n                        ") # Maintain indentation

    # Replace the placeholder with generated nav items
    html.gsub('{{nav_items}}', nav_items_html)
  end

  def extract_nav_item_template(pattern_config)
    # Handle different pattern config formats
    case pattern_config
    when String
      # If it's a string, it's the template
      pattern_config
    when Hash
      # If it's a hash, look for template key or use the whole thing
      pattern_config['template'] || pattern_config.to_s
    else
      # Default fallback
      '<a href="#" class="text-gray-900 hover:text-blue-600 px-3 py-2 rounded-md text-sm font-medium transition duration-300">{{nav_item}}</a>'
    end
  end

  def process_simple_placeholders(html, component, theme)
    # Handle simple placeholders like {{logo}}
    # You can expand this based on your editable_fields
    if component.editable_fields.present?
      editable_fields = component.editable_fields.split(',').map(&:strip)

      editable_fields.each do |field|
        case field.downcase
        when 'logo'
          # Replace with default logo text or use theme-specific logo if available
          logo_text = theme&.name || "Logo"
          html = html.gsub("{{#{field}}}", logo_text)
          # Add more field types as needed
        end
      end
    end

    html
  end
end