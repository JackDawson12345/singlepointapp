class ComponentTypes < ActiveRecord::Migration[8.0]
  def change
    add_column :components, :component_type, :string
  end
end
