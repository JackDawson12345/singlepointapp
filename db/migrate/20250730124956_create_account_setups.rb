class CreateAccountSetups < ActiveRecord::Migration[8.0]
  def change
    create_table :account_setups do |t|
      t.references :user, null: false, foreign_key: true
      t.string :domain_name
      t.string :package_type
      t.string :support_option
      t.string :payment_method

      t.timestamps
    end
  end
end
