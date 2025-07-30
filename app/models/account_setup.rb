# app/models/account_setup.rb
class AccountSetup < ApplicationRecord
  belongs_to :user

  # Simplified validations - only validate presence, not step-specific
  validates :domain_name, presence: true, allow_blank: true
  validates :package_type, inclusion: { in: ['Bespoke', 'E-commerce'] }, allow_blank: true
  validates :support_option, inclusion: { in: ['Do it myself', 'I need help'] }, allow_blank: true
  validates :payment_method, inclusion: { in: ['stripe'] }, allow_blank: true

  def package_price
    case package_type
    when 'Bespoke'
      500
    when 'E-commerce'
      1000
    else
      0
    end
  end

  def completed?
    domain_name.present? && package_type.present? && support_option.present? && payment_method.present?
  end
end