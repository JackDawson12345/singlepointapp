class WebsiteAddPublished < ActiveRecord::Migration[8.0]
  def change
    add_column :websites, :published, :boolean
  end
end
