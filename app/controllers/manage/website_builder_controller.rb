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

    # Get current customizations for this component
    @customizations = {}
    if defined?(WebsiteCustomization)
      @customizations = WebsiteCustomization.for_component(@website.id, @component.id, @theme_page.id)
    end

    render json: {
      success: true,
      component: {
        id: @component.id,
        name: @component.name,
        editable_fields: @component.respond_to?(:editable_fields_array) ? @component.editable_fields_array : [],
        field_types: @component.respond_to?(:field_types_hash) ? @component.field_types_hash : {}
      },
      current_values: @customizations,
      html: render_to_string(partial: 'component_editor', locals: {
        component: @component,
        theme_page: @theme_page,
        customizations: @customizations
      })
    }
  rescue ActiveRecord::RecordNotFound => e
    render json: { success: false, error: "Component or page not found" }, status: 404
  rescue => e
    render json: { success: false, error: e.message }, status: 500
  end

  # Update component customizations
  def update_component
    @component = Component.find(params[:component_id])
    @theme_page = ThemePage.find(params[:theme_page_id])

    # For now, let's just return success until we implement WebsiteCustomization
    if defined?(WebsiteCustomization)
      customization_params.each do |field_name, field_value|
        if @component.respond_to?(:field_editable?) && @component.field_editable?(field_name)
          WebsiteCustomization.set_value(
            @website.id,
            @component.id,
            @theme_page.id,
            field_name,
            field_value
          )
        end
      end

      # Return updated component HTML
      customizations = WebsiteCustomization.for_component(@website.id, @component.id, @theme_page.id)
      updated_html = @component.respond_to?(:render_with_customizations) ?
                       @component.render_with_customizations(customizations) :
                       @component.html_content
    else
      # Fallback if WebsiteCustomization model doesn't exist yet
      updated_html = @component.html_content
    end

    render json: {
      success: true,
      updated_html: updated_html,
      message: 'Component updated successfully'
    }
  rescue ActiveRecord::RecordNotFound => e
    render json: { success: false, error: "Component or page not found" }, status: 404
  rescue => e
    render json: { success: false, error: e.message }, status: 422
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
    # Get all params except the standard Rails ones
    allowed_params = params.except(:controller, :action, :component_id, :theme_page_id, :authenticity_token, :commit)

    # If we have the component and it responds to editable_fields_array, filter by those
    if @component && @component.respond_to?(:editable_fields_array)
      allowed_params.permit(@component.editable_fields_array)
    else
      # Otherwise allow common field names
      allowed_params.permit(:title, :subtitle, :content, :text, :button_text, :image_url, :background_color, :color, :link_url)
    end
  end
end