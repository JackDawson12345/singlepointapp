class WebsiteChanges < ActiveRecord::Migration[8.0]
  def change
    remove_column :websites, :subdomain
  end
end
