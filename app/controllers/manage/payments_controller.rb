# app/controllers/manage/payments_controller.rb
class Manage::PaymentsController < ApplicationController
  before_action :authenticate_user!
  before_action :complete_account_setup

  def create_payment_intent
    account_setup = current_user.account_setup

    # Check if we have enough info to process payment (not necessarily completed)
    unless account_setup&.domain_name.present? &&
           account_setup&.package_type.present? &&
           account_setup&.support_option.present?
      render json: { error: 'Please complete all previous steps before payment' }, status: :unprocessable_entity
      return
    end

    begin
      # Create a PaymentIntent with Stripe
      intent = Stripe::PaymentIntent.create(
        amount: account_setup.package_price * 100, # Amount in cents
        currency: 'gbp',
        metadata: {
          user_id: current_user.id,
          account_setup_id: account_setup.id,
          package_type: account_setup.package_type,
          domain_name: account_setup.domain_name,
          support_option: account_setup.support_option,
          is_deposit: account_setup.is_deposit_payment?,
          full_package_price: account_setup.base_package_price,
          remaining_balance: account_setup.remaining_balance
        }
      )

      render json: {
        client_secret: intent.client_secret,
        amount: account_setup.package_price
      }
    rescue Stripe::CardError => e
      render json: { error: e.message }, status: :unprocessable_entity
    rescue Stripe::RateLimitError => e
      render json: { error: 'Too many requests made to the API too quickly' }, status: :too_many_requests
    rescue Stripe::InvalidRequestError => e
      render json: { error: 'Invalid parameters were supplied to Stripe' }, status: :bad_request
    rescue Stripe::AuthenticationError => e
      render json: { error: 'Authentication with Stripe failed' }, status: :unauthorized
    rescue Stripe::APIConnectionError => e
      render json: { error: 'Network communication with Stripe failed' }, status: :service_unavailable
    rescue Stripe::StripeError => e
      render json: { error: 'Something went wrong with Stripe' }, status: :internal_server_error
    rescue => e
      render json: { error: 'An unexpected error occurred' }, status: :internal_server_error
    end
  end

  def confirm_payment
    begin
      # Retrieve the payment intent to confirm it was successful
      intent = Stripe::PaymentIntent.retrieve(params[:payment_intent_id])

      if intent.status == 'succeeded'
        # Update account setup to mark as paid
        account_setup = AccountSetup.find(intent.metadata.account_setup_id)
        account_setup.update!(
          payment_status: 'paid',
          stripe_payment_intent_id: intent.id,
          paid_at: Time.current
        )

        render json: {
          success: true,
          message: 'Payment successful!',
          redirect_url: manage_dashboard_path
        }
      else
        render json: {
          error: 'Payment was not successful',
          status: intent.status
        }, status: :unprocessable_entity
      end
    rescue Stripe::StripeError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end
end