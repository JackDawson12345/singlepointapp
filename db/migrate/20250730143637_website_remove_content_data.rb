class WebsiteRemoveContentData < ActiveRecord::Migration[8.0]
  def change
    remove_column :websites, :content_data
  end
end
