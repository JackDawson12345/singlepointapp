class AddDomainNameIndex < ActiveRecord::Migration[8.0]
  def change
    add_index :account_setups, :domain_name, unique: true
  end
end
