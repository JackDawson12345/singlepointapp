# app/models/account_setup.rb
class AccountSetup < ApplicationRecord
  belongs_to :user

  # Only validate fields that are actually being set in the current step
  validates :package_type, inclusion: { in: ['Bespoke', 'E-commerce'] }, allow_blank: true
  validates :support_option, inclusion: { in: ['Do it myself', 'I need help'] }, allow_blank: true
  validates :payment_method, inclusion: { in: ['stripe'] }, allow_blank: true
  validates :payment_status, inclusion: { in: ['pending', 'paid', 'failed'] }, allow_blank: true, allow_nil: true

  # Domain name uniqueness validation
  validates :domain_name, uniqueness: { case_sensitive: false, message: "has already been taken by another user" }, allow_blank: true

  # Normalize domain name before saving
  before_save :normalize_domain_name

  def base_package_price
    case package_type
    when 'Bespoke'
      500
    when 'E-commerce'
      1000
    else
      0
    end
  end

  def package_price
    base_price = base_package_price

    # If customer needs help, only charge 20% deposit
    if support_option == 'I need help'
      (base_price * 0.20).to_i
    else
      base_price
    end
  end

  def remaining_balance
    return 0 if support_option == 'Do it myself'
    base_package_price - package_price
  end

  def is_deposit_payment?
    support_option == 'I need help'
  end

  def completed?
    domain_name.present? && package_type.present? && support_option.present? && payment_method.present?
  end

  def payment_completed?
    payment_status == 'paid' && stripe_payment_intent_id.present?
  end

  def paid?
    payment_status == 'paid'
  end

  def pending?
    payment_status == 'pending' || payment_status.blank?
  end

  def failed?
    payment_status == 'failed'
  end

  # Add this to determine the next incomplete step
  def next_incomplete_step
    return 'domain_name' if domain_name.blank?
    return 'package_type' if package_type.blank?
    return 'support_option' if support_option.blank?
    return 'payment_method' if payment_status != 'paid'
    nil # All steps completed
  end

  private

  def normalize_domain_name
    return unless domain_name.present?

    # Remove protocol and www, convert to lowercase
    normalized = domain_name.downcase
    normalized = normalized.gsub(/^https?:\/\//, '') # Remove http:// or https://
    normalized = normalized.gsub(/^www\./, '')       # Remove www.
    normalized = normalized.split('/').first         # Remove any path

    self.domain_name = normalized
  end
end