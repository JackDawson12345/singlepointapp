# app/controllers/manage/website_builder_controller.rb
class Manage::WebsiteBuilderController < ApplicationController
  layout 'manage'
  before_action :authenticate_user!
  before_action :customer?
  before_action :require_account_setup
  before_action :set_website

  def builder
    @websitePages = @website.theme.theme_pages
    @homePage = @websitePages.order(:component_order).first

    @components = Component.joins(:theme_page_components)
                           .where(theme_page_components: { theme_page_id: @homePage.id })
                           .order('theme_page_components.position')
    render layout: false
  end

  # Show editor interface for a specific component
  def edit_component
    @component = Component.find(params[:component_id])
    @theme_page = ThemePage.find(params[:theme_page_id])

    # Get current customizations
    @customizations = {}
    if defined?(WebsiteCustomization)
      @customizations = WebsiteCustomization.for_component(@website.id, @component.id, @theme_page.id)
    end

    Rails.logger.info "=== RENDERING PARTIAL WITH HTML FORMAT ==="
    Rails.logger.info "Component: #{@component.name}"

    begin
      # IMPORTANT: Force HTML format when rendering the partial
      html_content = render_to_string(
        partial: 'component_editor',
        locals: {
          component: @component,
          theme_page: @theme_page,
          customizations: @customizations
        },
        formats: [:html]  # <- This is the key fix!
      )

      Rails.logger.info "SUCCESS: Partial rendered successfully"

      render json: {
        success: true,
        component: {
          id: @component.id,
          name: @component.name,
          editable_fields: @component.respond_to?(:editable_fields_array) ? @component.editable_fields_array : [],
          field_types: @component.respond_to?(:field_types_hash) ? @component.field_types_hash : {}
        },
        current_values: @customizations,
        html: html_content
      }

    rescue => e
      Rails.logger.error "ERROR: Failed to render partial"
      Rails.logger.error "Error: #{e.message}"
      Rails.logger.error "Error class: #{e.class}"

      render json: {
        success: false,
        error: "Failed to render partial: #{e.message}"
      }, status: 500
    end
  rescue => e
    Rails.logger.error "OUTER ERROR: #{e.message}"
    render json: { success: false, error: e.message }, status: 500
  end

  # Update component customizations
  # Replace your update_component method in the WebsiteBuilderController with this:

  def update_component
    @component = Component.find(params[:component_id])
    @theme_page = ThemePage.find(params[:theme_page_id])

    Rails.logger.info "=== UPDATE COMPONENT ==="
    Rails.logger.info "Component: #{@component.name}"
    Rails.logger.info "Theme Page: #{@theme_page.id}"
    Rails.logger.info "Params: #{params.inspect}"
    Rails.logger.info "Customization params: #{customization_params.inspect}"

    begin
      if defined?(WebsiteCustomization)
        # Save each field
        customization_params.each do |field_name, field_value|
          Rails.logger.info "Saving field: #{field_name} = #{field_value}"

          if @component.respond_to?(:field_editable?) && @component.field_editable?(field_name)
            WebsiteCustomization.set_value(
              @website.id,
              @component.id,
              @theme_page.id,
              field_name,
              field_value
            )
            Rails.logger.info "Saved: #{field_name} = #{field_value}"
          else
            Rails.logger.info "Field #{field_name} is not editable, saving anyway for testing"
            # For now, save it anyway for testing
            WebsiteCustomization.set_value(
              @website.id,
              @component.id,
              @theme_page.id,
              field_name,
              field_value
            )
          end
        end

        # Get updated customizations and render new HTML
        customizations = WebsiteCustomization.for_component(@website.id, @component.id, @theme_page.id)
        updated_html = @component.respond_to?(:render_with_customizations) ?
                         @component.render_with_customizations(customizations) :
                         @component.html_content
      else
        Rails.logger.error "WebsiteCustomization model not found"
        updated_html = @component.html_content
      end

      Rails.logger.info "Successfully updated component"

      render json: {
        success: true,
        updated_html: updated_html,
        message: 'Component updated successfully',
        saved_fields: customization_params.keys
      }

    rescue => e
      Rails.logger.error "Error updating component: #{e.message}"
      Rails.logger.error e.backtrace.first(5).join("\n")

      render json: {
        success: false,
        error: e.message
      }, status: 422
    end
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "Component or page not found: #{e.message}"
    render json: { success: false, error: "Component or page not found" }, status: 404
  rescue => e
    Rails.logger.error "Unexpected error in update_component: #{e.message}"
    render json: { success: false, error: e.message }, status: 500
  end

  # Preview component changes without saving
  def preview_component
    @component = Component.find(params[:component_id])

    if defined?(WebsiteCustomization)
      # Get current customizations
      current_customizations = WebsiteCustomization.for_component(
        @website.id,
        @component.id,
        params[:theme_page_id]
      )

      # Merge with preview values
      preview_customizations = current_customizations.merge(customization_params)
      preview_html = @component.respond_to?(:render_with_customizations) ?
                       @component.render_with_customizations(preview_customizations) :
                       @component.html_content
    else
      preview_html = @component.html_content
    end

    render json: {
      success: true,
      preview_html: preview_html
    }
  rescue => e
    render json: { success: false, error: e.message }, status: 500
  end

  # Reset component to default values
  def reset_component
    @component = Component.find(params[:component_id])
    @theme_page = ThemePage.find(params[:theme_page_id])

    if defined?(WebsiteCustomization)
      WebsiteCustomization.where(
        website_id: @website.id,
        component_id: @component.id,
        theme_page_id: @theme_page.id
      ).destroy_all

      default_html = @component.respond_to?(:render_with_customizations) ?
                       @component.render_with_customizations({}) :
                       @component.html_content
    else
      default_html = @component.html_content
    end

    render json: {
      success: true,
      updated_html: default_html,
      message: 'Component reset to default'
    }
  rescue => e
    render json: { success: false, error: e.message }, status: 500
  end

  private

  def set_website
    @website = current_user.website
    redirect_to manage_dashboard_path, alert: 'Please create a website first.' unless @website
  end

  def customization_params
    Rails.logger.info "Raw params: #{params.inspect}"

    # Get all params except the standard Rails ones
    allowed_params = params.except(:controller, :action, :component_id, :theme_page_id, :authenticity_token, :commit, :_method)

    Rails.logger.info "Filtered params: #{allowed_params.inspect}"

    # If we have the component and it responds to editable_fields_array, filter by those
    if @component && @component.respond_to?(:editable_fields_array)
      editable_fields = @component.editable_fields_array
      Rails.logger.info "Component editable fields: #{editable_fields}"

      if editable_fields.any?
        # Only permit the editable fields
        result = allowed_params.permit(editable_fields)
      else
        # If no editable fields defined, allow common field names
        result = allowed_params.permit(:title, :subtitle, :content, :text, :button_text, :image_url, :background_color, :color, :link_url)
      end
    else
      # Otherwise allow common field names
      result = allowed_params.permit(:title, :subtitle, :content, :text, :button_text, :image_url, :background_color, :color, :link_url)
    end

    Rails.logger.info "Final permitted params: #{result.inspect}"
    result
  end

  def build_editor_modal(component, theme_page, editable_fields, field_types, customizations)
    # Build form fields
    form_fields_html = ""

    if editable_fields.empty?
      form_fields_html = <<~HTML
      <div style="background: #fef3cd; border: 1px solid #f59e0b; padding: 1rem; border-radius: 0.5rem; margin-bottom: 1rem;">
        <p style="color: #92400e; margin: 0;">This component doesn't have editable fields configured yet.</p>
      </div>
      <div style="margin-bottom: 1rem;">
        <label style="display: block; font-weight: 500; margin-bottom: 0.5rem;">Title (Demo)</label>
        <input type="text" name="title" value="#{customizations['title'] || 'Sample Title'}" style="width: 100%; padding: 0.5rem; border: 1px solid #d1d5db; border-radius: 0.375rem;">
      </div>
    HTML
    else
      editable_fields.each do |field_name|
        field_type = field_types[field_name] || 'text'
        current_value = customizations[field_name] || (component.respond_to?(:get_default_value) ? component.get_default_value(field_name) : "Default #{field_name.humanize}")

        form_fields_html += <<~HTML
        <div style="margin-bottom: 1rem;">
          <label style="display: block; font-weight: 500; margin-bottom: 0.5rem;">#{field_name.humanize}</label>
      HTML

        case field_type
        when 'textarea'
          form_fields_html += <<~HTML
          <textarea name="#{field_name}" rows="3" style="width: 100%; padding: 0.5rem; border: 1px solid #d1d5db; border-radius: 0.375rem;">#{current_value}</textarea>
        HTML
        when 'color'
          form_fields_html += <<~HTML
          <input type="color" name="#{field_name}" value="#{current_value}" style="height: 2.5rem; width: 5rem; border: 1px solid #d1d5db; border-radius: 0.375rem;">
        HTML
        else
          form_fields_html += <<~HTML
          <input type="text" name="#{field_name}" value="#{current_value}" style="width: 100%; padding: 0.5rem; border: 1px solid #d1d5db; border-radius: 0.375rem;">
        HTML
        end

        form_fields_html += "</div>"
      end
    end

    # Build complete modal HTML
    <<~HTML
    <div class="component-editor-modal" id="component-editor-#{component.id}">
      <div style="position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(75, 85, 99, 0.5); z-index: 50; display: flex; align-items: center; justify-content: center;">
        <div style="background: white; padding: 2rem; border-radius: 0.5rem; width: 90%; max-width: 600px; max-height: 90vh; overflow-y: auto;">
          
          <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem;">
            <h3 style="font-size: 1.125rem; font-weight: 600; margin: 0;">Edit #{component.name}</h3>
            <button type="button" class="close-editor" style="background: none; border: none; font-size: 1.5rem; cursor: pointer; color: #6b7280;">✕</button>
          </div>
          
          <form action="#{manage_update_component_path(component_id: component.id, theme_page_id: theme_page.id)}" method="post" class="component-editor-form" data-remote="true">
            <input type="hidden" name="_method" value="patch">
            <input type="hidden" name="authenticity_token" value="#{form_authenticity_token}">
            
            #{form_fields_html}
            
            <div style="display: flex; justify-content: space-between; align-items: center; padding-top: 1rem; border-top: 1px solid #e5e7eb;">
              <button type="button" class="reset-component-btn" style="color: #dc2626; background: none; border: none; cursor: pointer;">Reset to Default</button>
              <div style="display: flex; gap: 0.5rem;">
                <button type="button" class="preview-btn" style="padding: 0.5rem 1rem; border: 1px solid #d1d5db; border-radius: 0.375rem; background: white; cursor: pointer;">Preview</button>
                <button type="submit" style="padding: 0.5rem 1rem; background: #3b82f6; color: white; border: none; border-radius: 0.375rem; cursor: pointer;">Save Changes</button>
              </div>
            </div>
          </form>
          
        </div>
      </div>
    </div>
  HTML
  end

end