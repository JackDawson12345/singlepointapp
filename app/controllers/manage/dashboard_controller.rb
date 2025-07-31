# app/controllers/manage/dashboard_controller.rb
class Manage::DashboardController < ApplicationController
  layout 'manage'
  before_action :authenticate_user!
  before_action :customer?
  before_action :require_account_setup

  def index
    @website = current_user.website

    if @website
      @website_stats = {
        pages: @website.theme.theme_pages.count,
        components: @website.theme.theme_pages.joins(:theme_page_components).count,
        customizations: @website.website_customizations.count,
        last_updated: @website.updated_at
      }
    end
  end

  def website
    # Existing method
  end

  def website_create
    @user = current_user
  end

  def website_create_save
    return redirect_to login_path, alert: 'Please log in first.' unless current_user

    # Check if user already has a website (since it's has_one)
    if current_user.website.present?
      redirect_to manage_dashboard_path, alert: 'You already have a website.'
      return
    end

    @website = current_user.build_website(website_params)

    if @website.save
      # Redirect to website editor instead of dashboard
      redirect_to manage_website_builder_path, notice: 'Website created! Start customizing your theme.'
    else
      @user = current_user
      flash.now[:alert] = 'There was an error creating your website.'
      render :website_create
    end
  end

  def website_settings
    @website = current_user.website
    @domain_name = current_user.account_setup.domain_name
  end

  # New method to handle website updates from settings
  def update_website_settings
    @website = current_user.website

    if @website.update(website_settings_params)
      redirect_to manage_website_settings_path, notice: 'Website settings updated successfully.'
    else
      @domain_name = current_user.account_setup.domain_name
      flash.now[:alert] = 'There was an error updating your website settings.'
      render :website_settings
    end
  end

  # Preview website as customer would see it
  def preview_website
    @website = current_user.website
    @theme_pages = @website.theme.theme_pages.order(:component_order)

    # Set the first page as active by default, or use the requested page
    @current_page = if params[:page_id].present?
                      @theme_pages.find(params[:page_id])
                    else
                      @theme_pages.first
                    end

    # Get all components for the current page
    @components = Component.joins(:theme_page_components)
                           .where(theme_page_components: { theme_page_id: @current_page.id })
                           .order('theme_page_components.position')

    render layout: 'website_preview'
  end

  private

  def website_params
    params.permit(:website_name, :theme_id).tap do |whitelisted|
      whitelisted[:name] = whitelisted.delete(:website_name) if whitelisted[:website_name]
      whitelisted[:published] = false
    end
  end

  def website_settings_params
    params.require(:website).permit(:name, :published)
  end
end