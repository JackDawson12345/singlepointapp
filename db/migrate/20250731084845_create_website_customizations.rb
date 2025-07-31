class CreateWebsiteCustomizations < ActiveRecord::Migration[8.0]
  def change
    create_table :website_customizations do |t|
      t.references :website, null: false, foreign_key: true
      t.references :component, null: false, foreign_key: true
      t.references :theme_page, null: false, foreign_key: true
      t.string :field_name, null: false
      t.text :field_value
      t.timestamps
    end

    # Add indexes for better query performance
    add_index :website_customizations, [:website_id, :component_id, :theme_page_id],
              name: 'index_website_customizations_on_website_component_page'
    add_index :website_customizations, [:website_id, :field_name]

    # Ensure unique combination of website, component, theme_page, and field_name
    add_index :website_customizations, [:website_id, :component_id, :theme_page_id, :field_name],
              unique: true, name: 'unique_website_component_field'
  end
end