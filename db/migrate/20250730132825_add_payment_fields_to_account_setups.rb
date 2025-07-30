class AddPaymentFieldsToAccountSetups < ActiveRecord::Migration[8.0]
  def change
    add_column :account_setups, :payment_status, :integer, default: 0
    add_column :account_setups, :stripe_payment_intent_id, :string
    add_column :account_setups, :paid_at, :datetime

    add_index :account_setups, :stripe_payment_intent_id
    add_index :account_setups, :payment_status
  end
end
