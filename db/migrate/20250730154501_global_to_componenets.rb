class GlobalToComponenets < ActiveRecord::Migration[8.0]
  def change
    add_column :components, :global, :boolean
  end
end
