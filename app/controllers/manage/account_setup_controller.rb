# app/controllers/manage/account_setup_controller.rb
class Manage::AccountSetupController < ApplicationController
  before_action :authenticate_user!
  before_action :set_account_setup, only: [:show, :update]
  before_action :complete_account_setup
  layout 'manage'

  STEPS = %w[domain_name package_type support_option payment_method].freeze

  def show
    @step = params[:step] || 'domain_name'
    redirect_to manage_account_setup_path(step: 'domain_name') unless valid_step?

    @account_setup ||= current_user.account_setup || current_user.build_account_setup
    @current_step_index = STEPS.index(@step)
    @total_steps = STEPS.length
  end

  def update
    @step = params[:step]
    @account_setup = current_user.account_setup || current_user.build_account_setup
    @current_step_index = STEPS.index(@step)
    @total_steps = STEPS.length

    # Debug logging
    Rails.logger.info "=== ACCOUNT SETUP DEBUG ==="
    Rails.logger.info "Current step: #{@step}"
    Rails.logger.info "All params: #{params.inspect}"
    Rails.logger.info "Account setup params: #{account_setup_params.inspect}"
    Rails.logger.info "Current account_setup attributes: #{@account_setup.attributes.inspect}"
    Rails.logger.info "Account setup valid?: #{@account_setup.valid?}"
    Rails.logger.info "Account setup errors before update: #{@account_setup.errors.full_messages}"

    if @account_setup.update(account_setup_params)
      Rails.logger.info "Account setup updated successfully"
      next_step = next_step_for(@step)

      if next_step
        Rails.logger.info "Redirecting to next step: #{next_step}"
        redirect_to "/manage/account-setup/#{next_step}"
      else
        # All steps completed - show payment page instead of redirecting
        Rails.logger.info "All steps completed, staying on payment step for processing"
        flash.now[:notice] = 'Please complete your payment to finish setup'
        render :show
      end
    else
      Rails.logger.error "=== ACCOUNT SETUP UPDATE FAILED ==="
      Rails.logger.error "Errors: #{@account_setup.errors.full_messages}"
      Rails.logger.error "Invalid attributes: #{@account_setup.errors.messages}"

      # Add flash message for debugging
      flash.now[:alert] = "Please fix the following errors: #{@account_setup.errors.full_messages.join(', ')}"
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_account_setup
    @account_setup = current_user.account_setup || current_user.build_account_setup
  end

  def account_setup_params
    params.require(:account_setup).permit(:domain_name, :package_type, :support_option, :payment_method)
  end

  def valid_step?
    STEPS.include?(@step)
  end

  def next_step_for(current_step)
    current_index = STEPS.index(current_step)
    return nil if current_index.nil? || current_index >= STEPS.length - 1

    STEPS[current_index + 1]
  end
end