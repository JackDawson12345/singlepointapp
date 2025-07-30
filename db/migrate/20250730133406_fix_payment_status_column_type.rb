class FixPaymentStatusColumnType < ActiveRecord::Migration[8.0]
  def up
    # Since the table is empty, we can just change the column type
    change_column :account_setups, :payment_status, :string, default: 'pending'
  end

  def down
    change_column :account_setups, :payment_status, :integer, default: 0
  end
end
