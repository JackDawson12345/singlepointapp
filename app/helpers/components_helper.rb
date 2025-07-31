# app/helpers/components_helper.rb
module ComponentsHelper
  def render_component_for_website(component, theme_page, website = nil)
    Rails.logger.info "=== RENDERING COMPONENT WITH CUSTOMISATIONS ==="
    Rails.logger.info "Component: #{component.name} (ID: #{component.id})"
    Rails.logger.info "Theme Page: #{theme_page.id}"
    Rails.logger.info "Website: #{website&.id}"

    html = component.html_content || ""
    Rails.logger.info "Original HTML: #{html[0..100]}..."

    if website
      customisations = WebsiteCustomization.for_component(website.id, component.id, theme_page.id)
      Rails.logger.info "Found customisations: #{customisations.inspect}"

      if customisations.any?
        if component.respond_to?(:render_with_customisations)
          html = component.render_with_customisations(customisations)
          Rails.logger.info "Applied customisations via component method"
        else
          customisations.each do |field_name, field_value|
            placeholder = "{{#{field_name}}}"
            html = html.gsub(placeholder, field_value.to_s)
            Rails.logger.info "Replaced #{placeholder} with #{field_value}"
          end
        end
      else
        Rails.logger.info "No customisations found, using defaults"
        html = process_basic_placeholders(html, component)
      end
    else
      Rails.logger.info "No website provided, using defaults"
      html = process_basic_placeholders(html, component)
    end

    # Continue processing template patterns and placeholders
    if component.template_patterns.present?
      html = process_template_patterns(html, component.template_patterns, theme_page&.theme, theme_page)
    end

    html = process_simple_placeholders(html, component, theme_page&.theme)

    if params[:action] == 'builder' && website
      html = wrap_component_for_editing(html, component, theme_page)
    end

    Rails.logger.info "Final HTML: #{html[0..100]}..."

    html.html_safe
  end

  def process_component_template(component, theme = nil, current_page = nil)
    return component.html_content if component.html_content.blank?

    html = component.html_content.dup

    if component.template_patterns.present?
      html = process_template_patterns(html, component.template_patterns, theme, current_page)
    end

    html = process_simple_placeholders(html, component, theme)

    html
  end

  def component_field_types_json(component)
    if component.respond_to?(:field_types_hash)
      component.field_types_hash.to_json
    else
      '{}'.to_json
    end
  end

  def component_customisations_json(component, theme_page, website)
    if defined?(WebsiteCustomization) && website
      WebsiteCustomization.for_component(website.id, component.id, theme_page.id).to_json
    else
      '{}'.to_json
    end
  end

  private

  def process_template_patterns(html, template_patterns_json, theme, current_page = nil)
    begin
      patterns = JSON.parse(template_patterns_json)

      patterns.each do |placeholder, pattern_config|
        case placeholder
        when 'nav_items'
          html = process_nav_items(html, pattern_config, theme, current_page)
        end
      end
    rescue JSON::ParserError => e
      Rails.logger.error "Failed to parse template patterns: #{e.message}"
    end

    html
  end

  def process_nav_items(html, pattern_config, theme, current_page = nil)
    return html unless theme&.theme_pages&.any?

    nav_item_template = extract_nav_item_template(pattern_config)

    nav_items_html = theme.theme_pages.order(:component_order).map do |theme_page|
      preview_url = Rails.application.routes.url_helpers.admin_preview_theme_page_path(
        theme_id: theme.id,
        id: theme_page.id
      )

      nav_item_html = nav_item_template.gsub('{{nav_item}}', theme_page.page_type)
      nav_item_html = nav_item_html.gsub('href="#"', "href=\"#{preview_url}\"")

      if current_page && current_page.id == theme_page.id
        nav_item_html = nav_item_html.gsub(
          'text-gray-900 hover:text-blue-600',
          'text-blue-600 font-semibold bg-blue-50'
        )
      end

      nav_item_html
    end.join("\n                        ")

    html.gsub('{{nav_items}}', nav_items_html)
  end

  def extract_nav_item_template(pattern_config)
    case pattern_config
    when String
      pattern_config
    when Hash
      pattern_config['template'] || pattern_config.to_s
    else
      '<a href="#" class="text-gray-900 hover:text-blue-600 px-3 py-2 rounded-md text-sm font-medium transition duration-300">{{nav_item}}</a>'
    end
  end

  def process_simple_placeholders(html, component, theme)
    if component.editable_fields.present?
      editable_fields = component.editable_fields.split(',').map(&:strip)

      editable_fields.each do |field|
        case field.downcase
        when 'logo'
          logo_text = theme&.name || "Logo"
          html = html.gsub("{{#{field}}}", logo_text)
        end
      end
    end

    html
  end

  def process_basic_placeholders(html, component)
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
end
