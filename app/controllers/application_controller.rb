class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def admin?
    unless current_user.admin?
      redirect_to manage_dashboard_path, alert: "Redirected to manage dashboard."
    end
  end

  def customer?
    if current_user.admin?
      redirect_to admin_dashboard_path, alert: "Redirected to admin dashboard."
    end
  end

  def account_setup?
    if !current_user.admin? && !current_user.account_setup
      byebug
    end
  end
end
