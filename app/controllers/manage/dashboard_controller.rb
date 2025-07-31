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
        last_updated: @website.updated_at
      }
    end


  end

  def website

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
      redirect_to manage_dashboard_path, notice: 'Website was successfully created.'
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

  private
  def website_params
    params.permit(:website_name, :theme_id).tap do |whitelisted|
      whitelisted[:name] = whitelisted.delete(:website_name) if whitelisted[:website_name]
      whitelisted[:published] = false
    end
  end
end
