class CreateAdminThemePageComponents < ActiveRecord::Migration[8.0]
  def change
    create_table :theme_page_components do |t|
      t.references :theme_page, null: false, foreign_key: true
      t.references :component, null: false, foreign_key: true
      t.integer :position

      t.timestamps
    end
  end
end
