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

  def require_account_setup
    return if current_user.admin? # Skip for admins

    # If no account setup exists, redirect to start
    unless current_user.account_setup
      redirect_to manage_account_setup_path and return
    end

    setup = current_user.account_setup

    # If payment is already completed, they're done
    return if setup.payment_status == 'paid'

    # Determine which step they need to complete next
    if setup.domain_name.blank?
      redirect_to "/manage/account-setup/domain_name" and return
    elsif setup.package_type.blank?
      redirect_to "/manage/account-setup/package_type" and return
    elsif setup.support_option.blank?
      redirect_to "/manage/account-setup/support_option" and return
    else
      # All info is complete, they need to pay
      redirect_to "/manage/account-setup/payment_method" and return
    end
  end

  def complete_account_setup
    return if current_user.admin?

    if current_user.account_setup.payment_status == 'paid'
      redirect_to manage_dashboard_path and return
    end

  end

  protected

  def after_sign_in_path_for(resource)
    if resource.admin?
      admin_dashboard_path
    else
      manage_dashboard_path
    end
  end

end
