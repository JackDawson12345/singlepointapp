class ThemePagesPackage < ActiveRecord::Migration[8.0]
  def change
    add_column :theme_pages, :package, :string
  end
end
