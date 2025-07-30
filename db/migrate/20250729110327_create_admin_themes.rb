class CreateAdminThemes < ActiveRecord::Migration[8.0]
  def change
    create_table :themes do |t|
      t.string :name
      t.string :placeholder_image

      t.timestamps
    end
  end
end
